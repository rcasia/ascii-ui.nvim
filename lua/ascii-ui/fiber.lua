local Buffer = require("ascii-ui.buffer")
local EventListener = require("ascii-ui.events")
local config = require("ascii-ui.config")

local logger = require("ascii-ui.logger")

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

local currentFiber

--- @param fiber ascii-ui.FiberNode
local function performUnitOfWork(fiber)
	assert(fiber, "Fiber cannot be nil")

	currentFiber = fiber
	fiber.hookIndex = 1
	fiber.hooks = fiber.hooks or {}
	fiber.root = fiber

	if fiber.closure then
		local lines, result = fiber.closure(config)
		fiber.output = result
		if not fiber.output then
			if lines and type(lines) == "function" then
				-- Si lines es una función, la ejecutamos para obtener el resultado
				local result2 = lines(config)
				fiber.output = result2()
			else
				assert(type(lines) == "table", "lines should be a table or a function, got: " .. type(lines))
				fiber.output = lines
			end
		end
		assert(type(fiber.output) == "table", "Expected fiber.output to return a table, got: " .. type(fiber.output))

		reconcileChildren(fiber, fiber.output)
	else
		-- error("fiber.closure cannot be nil on: " .. vim.inspect(fiber))
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

	logger.debug("llegó")
end
-- helper de alto nivel: recibe un componente y devuelve las líneas del buffer
local function render(Component)
	local _, fiberArr = Component()
	local root = fiberArr[1] --- @cast root ascii-ui.FiberNode
	workLoop(root)
	local buffer = Buffer.new()
	commitWork(root, buffer)
	return buffer, root
end

--- Re-renderiza el árbol de fibers a partir de la raíz dada
--- @param root ascii-ui.FiberNode
--- @return ascii-ui.Buffer buffer con las líneas renderizadas
local function rerender(root)
	-- Vuelve a procesar todos los units of work
	workLoop(root)
	-- Genera un nuevo buffer con el commit de toda la estructura
	local buf = Buffer.new()
	commitWork(root, buf)
	-- Guarda el resultado en root para posibles inspecciones
	root.lastRendered = buf
	return buf
end

local function useState(initial)
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
		if type(value) == "function" then
			fiber.hooks[idx] = value(fiber.hooks[idx])
		else
			fiber.hooks[idx] = value
		end
		-- re-render completo sobre el mismo root
		workLoop(fiber.root)
		local buf = Buffer.new()
		commitWork(fiber.root, buf)
		assert(buf, "buf cannot be nil")
		fiber.root.lastRendered = buf

		EventListener:trigger("state_change")
	end

	fiber.hookIndex = idx + 1
	return get, set
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
			for i, h in ipairs(node.hooks) do
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
	useState = useState,
	workLoop = workLoop,
	commitWork = commitWork,
	debugPrint = debugPrint,
}
