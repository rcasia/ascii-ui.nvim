local Buffer = require("ascii-ui.buffer")
local EventListener = require("ascii-ui.events")
local unpack = unpack or table.unpack
local FiberNode = require("ascii-ui.fibernode")

local logger = require("ascii-ui.logger")

--- @type ascii-ui.FiberNode | nil
local currentFiber

---
--- Debug: Imprime el árbol de Fibers con indentación y valores de hooks
---
local function debugPrint(fiber, print_fn)
	--- @param node ascii-ui.FiberNode
	local function traverse(node, prefix, isLast)
		local print = print_fn or logger.debug
		-- Construye línea con prefijo gráfico
		local branch = isLast and "└─ " or "├─ "
		local line = prefix .. branch .. (node.type or "<buffer>")
		-- Agrega estados de hooks si existen
		if node.hooks and #node.hooks > 0 then
			local parts = {}
			for _, h in ipairs(node.hooks) do
				parts[#parts + 1] = tostring(h)
			end
			line = line .. " [hooks=" .. table.concat(parts, ",") .. "]"
		end
		if node.tag then
			line = line .. " " .. node.tag
		end
		if node:is_leaf() then
			line = string.format("%s %s", line, node:get_line():to_string())
		end
		print(line)
		-- Recorre hijos
		local children = {}
		local child = node.child
		while child do
			children[#children + 1] = child
			child = child.sibling
		end
		-- Recurse
		for i, c in ipairs(children) do
			local last = (i == #children)
			traverse(c, prefix .. (isLast and "   " or "│  "), last)
		end
	end
	traverse(fiber, "", true)
end

--- @param parent ascii-ui.FiberNode
--- @param new_children ascii-ui.FiberNode[]
local function reconcileChildren(parent, new_children)
	assert(type(new_children) == "table", "new_children should be a table, got: " .. type(new_children))
	assert(parent.output or parent.tag == "PLACEMENT" or parent.tag == "REPLACEMENT")
	assert(
		--- @param node ascii-ui.FiberNode
		vim.iter(new_children):all(function(node)
			return FiberNode.is_node(node)
		end),
		"cannot reconcile parent with objects that are not FiberNodes"
	)

	logger.debug(
		"🧑‍🧑‍🧒‍🧒🧑‍🧑‍🧒‍🧒🧑‍🧑‍🧒‍🧒 Reconciling children of %s",
		parent.type
	)

	parent.child = nil
	local prevSibling
	for i, node in ipairs(new_children) do
		node.parent = parent
		node.root = parent.root or parent
		local old = parent.output and parent.output[i] or {}
		logger.debug(
			"reconcilitation against: %s",
			vim.inspect({
				--
				new = ("(type: %s, tag: %s)"):format(node.type, node.tag),
				old = ("(type: %s, tag: %s)"):format(old.type, old.tag),
			})
		)

		node.props = node.props or {}
		local new_child
		if not node:is_leaf() and (FiberNode.is_node(old) and vim.tbl_isempty(node.props) or node:is_same(old)) then
			logger.debug("⛓️ reused link ", parent.type, old.type)
			new_child = old
		else
			logger.debug(
				"⛓️‍💥 -> ⛓️ new link %s -> %s. Because [is_empty=%s, is_same=%s]",
				parent.type,
				node.type,
				vim.tbl_isempty(node.props),
				node:is_same(old)
			)
			new_child = node
		end

		if i == 1 then
			parent.child = new_child
		else
			prevSibling.sibling = new_child
		end
		prevSibling = new_child
	end
end

--- @param fiber ascii-ui.RootFiberNode
local function performUnitOfWork(fiber)
	assert(fiber, "Fiber cannot be nil")

	if fiber.tag == "NONE" then
		return -- does not need work
	end

	currentFiber = FiberNode.resetFrom(fiber)
	fiber.root = fiber

	if fiber.closure then
		local new_children = fiber:unwrap_closure()
		local old_child = fiber.output and fiber.output[1] or {}
		local new_child = new_children[1]

		logger.debug("🧑‍🧒‍🧒 children of %s", fiber.type)
		--- @param child ascii-ui.FiberNode
		vim.iter(new_children):enumerate():each(function(i, child)
			logger.debug("🧒 %d. %s", i, child.type)
		end)

		if #new_children > 1 then
			logger.debug("🪺 nested unit of work for: %s", fiber.type)
			for _, node in ipairs(new_children) do
				node.tag = fiber.tag
			end

			reconcileChildren(fiber, new_children)
			fiber.output = new_children
			fiber.tag = "NONE"
			return -- do nothing
		end

		logger.debug("tag check: %s [%s]", fiber.type, fiber.tag)

		if fiber.tag == "UPDATE" and not fiber:is_leaf() then
			if not new_child:is_leaf() and new_child:is_same(old_child) then
				new_child.tag = "NONE"
				logger.debug("🫥 Child node has NOT changed: %s", old_child.type)
				return -- do nothing else
			elseif vim.isarray(new_child.props) then
				logger.debug("♻️♻️♻️ Multiple children nodes has changed: %s", new_child.type)

				local fiber_child_children = vim.iter(new_child:unwrap_closure())
					:map(function(node)
						node.tag = "REPLACEMENT"
						return node
					end)
					:totable()

				reconcileChildren(fiber.child, fiber_child_children)
				logger.debug("🛫🛫🛫🛫🛫")
				debugPrint(fiber.child)
				logger.debug("🛫🛫🛫🛫🛫")
				reconcileChildren(fiber, { fiber.child })

				logger.debug("🛫🛫🛫🛫🛫")
				debugPrint(fiber)
				logger.debug("🛫🛫🛫🛫🛫")
				fiber.output = new_children
				fiber.child.tag = "NONE"
				fiber.tag = "NONE"
				return
			else
				logger.debug("♻️ Child node has changed: %s", new_child.type)

				reconcileChildren(fiber, new_children)
				fiber.output = new_children
				fiber.tag = "NONE"
				return
			end
		end

		assert(type(new_children) == "table", "Expected fiber.output to return a table, got: " .. type(new_children))

		reconcileChildren(fiber, new_children)
		fiber.output = new_children
		fiber.tag = "NONE"
	end
end

--- @param fiber ascii-ui.FiberNode
--- @param buffer ascii-ui.Buffer
local function commitWork(fiber, buffer)
	if not fiber then
		return
	end
	if fiber:is_leaf() then
		buffer:add(fiber:get_line())
		return
	end

	local child = fiber.child
	while child do
		commitWork(child, buffer)
		child = child.sibling
	end
end

-- recorre todos los Units of Work automáticamente
--- @param root ascii-ui.RootFiberNode
local function workLoop(root)
	local nextFiber = root
	while nextFiber do
		performUnitOfWork(nextFiber)
		nextFiber = nextFiber:next()
	end
end
-- helper de alto nivel: recibe un componente y devuelve las líneas del buffer
local function render(Component)
	logger.debug("📺 FIBER.RENDER")
	local fiberArr = Component()
	local root = fiberArr[1] --- @cast root ascii-ui.RootFiberNode
	-- first phase: reconcile
	workLoop(root)
	local buffer = Buffer.new()
	-- second phase: commit
	commitWork(root, buffer)

	-- third phase: execute pending effects
	--- @param n ascii-ui.FiberNode
	vim.iter(root:iter()):each(function(n)
		n:run_pending()
		n.tag = "NONE"
	end)
	return buffer, root
end

--- Re-renderiza el árbol de fibers a partir de la raíz dada
--- @param root ascii-ui.RootFiberNode
--- @return ascii-ui.Buffer buffer con las líneas renderizadas
local function rerender(root)
	logger.debug("📺📺 FIBER.RERENDER")
	local buf = Buffer.new()

	commitWork(root, buf)

	--- @param n ascii-ui.FiberNode
	vim.iter(root:iter()):each(function(n)
		n:run_pending()
		n.tag = "NONE"
	end)

	logger.debug("MYBUF" .. buf:to_string())
	return buf
end

local function useState(initial)
	assert(currentFiber, "cannot call useState out of context")
	local fiber = currentFiber

	assert(fiber.root, "fiber should have root: " .. vim.inspect(fiber))
	local idx = fiber.hookIndex
	if fiber.hooks[idx] == nil then
		fiber.hooks[idx] = initial
	end
	local snapshot = fiber.hooks[idx]

	local function get()
		return snapshot -- siempre el mismo durante este render
	end

	local function set(value)
		logger.debug("🥊 State change detected: (component: %s, state: %s)", fiber.type, vim.inspect(value))
		if type(value) == "function" then
			fiber.hooks[idx] = value(fiber.hooks[idx])
		else
			fiber.hooks[idx] = value
		end

		-- ⇲ 2) P1 – ejecuta cleanups de efectos con deps no-vacíos ------
		if fiber.cleanups then
			for i, cu in ipairs(fiber.cleanups) do
				local deps = fiber.prevDeps[i]
				-- solo si deps existe y no está vacío
				if deps and #deps > 0 and type(cu) == "function" then
					cu() -- cleanup inmediato (mantiene valor viejo)
					fiber.cleanups[i] = nil -- se reasignará en el nuevo render
					fiber.prevDeps[i] = nil
				end
			end
		end

		local root = FiberNode.resetFrom(fiber)
		vim.iter(fiber:iter()):each(function(n)
			n.tag = "UPDATE"
		end)
		workLoop(root)

		debugPrint(root)

		EventListener:trigger("state_change")
	end

	fiber.hookIndex = idx + 1
	return get, set
end

--- @param fn function
--- @param deps? any[]
local function useEffect(fn, deps)
	assert(currentFiber, "cannot call useEffect out of the component scope")
	assert(type(deps) == "nil" or vim.isarray(deps), "deps should be an array or nil")

	local fiber = currentFiber

	logger.debug("running useEffect on %s", fiber.type)

	local idx = fiber.effectIndex
	local prev = fiber.prevDeps[idx]
	local shouldRun = false

	if deps == nil then
		-- Sin array de deps: ejecutar en cada render y rerender
		shouldRun = true
	elseif #deps == 0 then
		-- Array vacío: sólo montaje
		shouldRun = (prev == nil)
	else
		if not prev then
			shouldRun = true
		else
			-- Shallow compare
			if #deps ~= #prev then
				shouldRun = true
			else
				for i = 1, #deps do
					if deps[i] ~= prev[i] then
						shouldRun = true
						break
					end
				end
			end
		end
	end

	logger.debug("shouldRun: " .. tostring(shouldRun))

	if shouldRun then
		local prevCleanup = fiber.cleanups[idx]

		local effect_type = deps and "ONCE" or "REPEATING"
		if effect_type == "ONCE" then
			if prevCleanup then
				fiber:add_cleanup(prevCleanup)
			end
			fiber:add_effect(function()
				local newCleanup = fn()
				fiber.cleanups[idx] = type(newCleanup) == "function" and newCleanup or nil
			end, effect_type)
		else
			fiber:add_effect(function()
				if fiber.cleanups[idx] then
					fiber.cleanups[idx]()
				end
				local newCleanup = fn()
				fiber.cleanups[idx] = type(newCleanup) == "function" and newCleanup or nil
			end, effect_type)
		end
	end

	-- guardar dependencias anteriores correctamente
	if deps == nil then
		fiber.prevDeps[idx] = nil
	elseif #deps == 0 then
		fiber.prevDeps[idx] = {} -- ← mantiene array vacío
	else
		fiber.prevDeps[idx] = { unpack(deps) }
	end
	fiber.effectIndex = fiber.effectIndex + 1
end

return {
	render = render,
	rerender = rerender,
	workLoop = workLoop,
	performUnitOfWork = performUnitOfWork,
	reconcileChildren = reconcileChildren,
	commitWork = commitWork,
	debugPrint = debugPrint,
	-- hooks
	useState = useState,
	useEffect = useEffect,
}
