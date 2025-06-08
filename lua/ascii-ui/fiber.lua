local Buffer = require("ascii-ui.buffer")
local EventListener = require("ascii-ui.events")
local config = require("ascii-ui.config")
local unpack = unpack or table.unpack
local FiberNode = require("ascii-ui.fibernode")
local is_callable = require("ascii-ui.utils.is_callable")

local logger = require("ascii-ui.logger")

--- @type ascii-ui.FiberNode | nil
local currentFiber

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
			fiber.cleanups = {}
		end
	end

	traverse(root)
end
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

--- @param fiber ascii-ui.RootFiberNode
local function performUnitOfWork(fiber)
	assert(fiber, "Fiber cannot be nil")

	currentFiber = FiberNode.resetFrom(fiber)
	fiber.root = fiber

	if fiber.closure then
		logger.debug("Performing unit of work for fiber: %s", fiber.type or "<unknown>")
		logger.debug("fiber.closure: %s", vim.inspect(fiber.closure))
		local result = fiber.closure(config)
		fiber.output = result

		-- unwrap fibernode from functions
		local limit = 10
		local current = 0
		while is_callable(fiber.output) and current < limit do
			if current >= limit then
				logger.warn("Reached maximum unwrapping limit for fiber.output, stopping to prevent infinite loop")
				break
			end
			current = current + 1
			fiber.output = fiber.output(config)
		end

		-- if not fiber.output then
		-- 	if lines and type(lines) == "function" then
		-- 		-- Si lines es una función, la ejecutamos para obtener el resultado
		-- 		local result2 = lines(config)
		-- 		if type(result2) ~= "function" then
		-- 			fiber.output = result2
		-- 		else
		-- 			fiber.output = result2()
		-- 		end
		-- 	else
		-- 		assert(type(lines) == "table", "lines should be a table or a function, got: " .. type(lines))
		-- 		fiber.output = lines
		-- 	end
		-- end
		assert(type(fiber.output) == "table", "Expected fiber.output to return a table, got: " .. type(fiber.output))

		reconcileChildren(fiber, fiber.output)
	end
end

--- @param fiber ascii-ui.FiberNode | ascii-ui.BufferLine
--- @param buffer ascii-ui.Buffer
local function commitWork(fiber, buffer)
	if not fiber then
		return
	end
	if type(fiber) == "table" and fiber.elements then --- @cast fiber ascii-ui.BufferLine
		buffer:add(fiber)
		return
	end
	if not fiber.child then
		return
	end
	local child = fiber.child
	while child do
		commitWork(child, buffer)
		child = child.sibling
	end

	for _, eff in ipairs(fiber.root.pendingEffects) do
		eff()
	end
	fiber.root.pendingEffects = {}
end

--- añade esta función para obtener el siguiente Fiber en recorrido depth-first
--- @param fiber ascii-ui.FiberNode
--- @return ascii-ui.FiberNode | nil
local function getNextFiber(fiber)
	if fiber.child then
		return fiber.child
	end
	local node = fiber
	while node do
		if node.sibling then
			return node.sibling
		end
		node = node.parent
	end
	return nil
end

-- recorre todos los Units of Work automáticamente
local function workLoop(root)
	local nextFiber = root
	while nextFiber do
		performUnitOfWork(nextFiber)
		nextFiber = getNextFiber(nextFiber)
	end
end
-- helper de alto nivel: recibe un componente y devuelve las líneas del buffer
local function render(Component)
	local fiberArr = Component()
	local root = fiberArr[1] --- @cast root ascii-ui.RootFiberNode
	-- first phase: reconcile
	workLoop(root)
	local buffer = Buffer.new()
	-- second phase: commit
	commitWork(root, buffer)

	-- third phase: execute pending effects
	for _, eff in ipairs(root.pendingEffects) do
		eff()
	end
	root.pendingEffects = {}
	return buffer, root
end

--- Re-renderiza el árbol de fibers a partir de la raíz dada
--- @param root ascii-ui.RootFiberNode
--- @return ascii-ui.Buffer buffer con las líneas renderizadas
local function rerender(root)
	unmount(root)

	root.pendingEffects = {}

	workLoop(root)
	local buf = Buffer.new()

	commitWork(root, buf)
	root.lastRendered = buf

	for _, eff in ipairs(root.pendingEffects) do
		eff()
	end
	root.pendingEffects = {}

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

	local function get()
		return fiber.hooks[idx]
	end

	local function set(value)
		local oldCleanup = fiber.cleanups and fiber.cleanups[idx]
		if oldCleanup then
			oldCleanup()
		end

		if type(value) == "function" then
			fiber.hooks[idx] = value(fiber.hooks[idx])
		else
			fiber.hooks[idx] = value
		end
		-- re-render completo sobre el mismo root
		local root = FiberNode.resetFrom(fiber.root)
		workLoop(root)
		local buf = Buffer.new()
		commitWork(root, buf)
		assert(buf, "buf cannot be nil")
		fiber.root.lastRendered = buf

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

	local idx = fiber.effectIndex
	local prev = fiber.prevDeps[idx]
	local shouldRun = false

	if deps == nil then
		logger.debug("nada: %s", vim.inspect(deps))

		-- Sin array de deps: ejecutar en cada render y rerender
		shouldRun = true
	elseif #deps == 0 then
		logger.debug("vacío")
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

	if shouldRun then
		table.insert(fiber.root.pendingEffects, function()
			local newCleanUp = fn()
			if type(newCleanUp) == "function" then
				fiber.cleanups[idx] = newCleanUp
			else
				fiber.cleanups[idx] = nil
			end
		end)
	end

	fiber.prevDeps[idx] = deps and { unpack(deps) } or nil
	fiber.effectIndex = fiber.effectIndex + 1
end

---
--- Debug: Imprime el árbol de Fibers con indentación y valores de hooks
---
local function debugPrint(fiber, print_fn)
	local function traverse(node, prefix, isLast)
		local print = print_fn or print
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

return {
	render = render,
	rerender = rerender,
	unmount = unmount,
	workLoop = workLoop,
	commitWork = commitWork,
	debugPrint = debugPrint,
	-- hooks
	useState = useState,
	useEffect = useEffect,
}
