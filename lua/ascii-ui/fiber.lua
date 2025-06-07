local MAX_RECURSION_LIMIT = 20
local current_recursion = 0
local Buffer = require("ascii-ui.buffer")

local function reconcileChildren(parent, output)
	assert(output, "output cannot be nil")
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
		local lines, result = fiber.closure()
		fiber.output = result or lines()
		reconcileChildren(fiber, fiber.output)
	else
		-- error("fiber.closure cannot be nil on: " .. vim.inspect(fiber))
	end
end

--- @param fiber ascii-ui.FiberNode
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
		assert(current_recursion < MAX_RECURSION_LIMIT, "MAX_RECURSION_LIMIT reached")
		current_recursion = current_recursion + 1
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
end
-- helper de alto nivel: recibe un componente y devuelve las líneas del buffer
local function render(Component)
	local _, fiberArr = Component()
	local root = fiberArr[1] --- @cast root ascii-ui.FiberNode
	workLoop(root)
	local buffer = Buffer.new()
	commitWork(root, buffer)
	return buffer
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
	end

	fiber.hookIndex = idx + 1
	return get, set
end

return {
	render = render,
	useState = useState,
	workLoop = workLoop,
	commitWork = commitWork,
}
