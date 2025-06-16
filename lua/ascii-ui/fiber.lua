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

--- @param root ascii-ui.FiberNode
local function unmount(root)
	--- @param fiber ascii-ui.FiberNode
	local function traverse(fiber)
		-- 1) Primero descendemos a todos los hijos (post-order)
		local children = {}
		local child = fiber.child
		while child do
			children[#children + 1] = child
			child = child.sibling
		end
		for _, c in ipairs(children) do
			traverse(c)
		end

		-- 2) Luego ejecutamos los cleanups de este fiber en orden inverso (LIFO)
		if fiber.cleanups then
			for i = #fiber.cleanups, 1, -1 do
				local cleanup = fiber.cleanups[i]
				if type(cleanup) == "function" then
					cleanup()
				end
			end
			-- fiber.cleanups = {}
		end
	end

	traverse(root)
end

--- @param parent ascii-ui.FiberNode
--- @param output ascii-ui.FiberNode[]
local function reconcileChildren(parent, output)
	assert(type(output) == "table", "output should be a table, got: " .. type(output))

	parent.child = nil
	local prevSibling
	for i, node in ipairs(output) do
		node.parent = parent
		node.root = parent.root or parent
		if i == 1 then
			parent.child = node
		else
			prevSibling.sibling = node
		end
		prevSibling = node
	end
end

local function shallow_equal(t1, t2)
	if t1 == t2 then
		return true
	end
	if type(t1) ~= "table" or type(t2) ~= "table" then
		return false
	end

	for k, v in pairs(t1) do
		if t2[k] ~= v then
			return false
		end
	end
	for k in pairs(t2) do
		if t1[k] == nil then
			return false
		end
	end

	return true
end

--- @param fiber ascii-ui.RootFiberNode
local function performUnitOfWork(fiber)
	assert(fiber, "Fiber cannot be nil")

	currentFiber = FiberNode.resetFrom(fiber)
	fiber.root = fiber

	if fiber.closure and fiber.tag ~= "NONE" then
		local output = fiber:unwrap_closure()
		local old = fiber.output and fiber.output[1] or {}
		local new = output[1]

		if
			not new:is_leaf()
			and old.type == new.type
			and (shallow_equal(old.props, new.props) or vim.isarray(new.props))
		then
			--- @param n ascii-ui.FiberNode
			vim.iter(fiber:iter()):each(function(n)
				n.tag = "NONE"
			end)
			return -- do nothing else
		end

		assert(type(output) == "table", "Expected fiber.output to return a table, got: " .. type(output))

		reconcileChildren(fiber, output)
		fiber.output = output
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
	logger.debug("FIBER.RENDER")
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
	logger.debug("FIBER.RERENDER")
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
		fiber.tag = "UPDATE"
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
	unmount = unmount,
	workLoop = workLoop,
	performUnitOfWork = performUnitOfWork,
	reconcileChildren = reconcileChildren,
	commitWork = commitWork,
	debugPrint = debugPrint,
	-- hooks
	useState = useState,
	useEffect = useEffect,
}
