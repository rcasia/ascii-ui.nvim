pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local logger = require("ascii-ui.logger")

local Buffer = require("ascii-ui.buffer")
local Element = require("ascii-ui.buffer.element")
local ui = require("ascii-ui")

--- @class ascii-ui.FiberNode
--- @field type "Root" | string
--- @field closure fun(): function, ascii-ui.FiberNode[]
--- @field output ascii-ui.FiberNode[] | ascii-ui.BufferLine[] | nil
--- @field root ascii-ui.FiberNode | nil
--- @field child ascii-ui.FiberNode | nil
--- @field sibling ascii-ui.FiberNode | nil
--- @field parent ascii-ui.FiberNode | nil
--- @field hookIndex integer
--- @field hooks table[]

local MyComponent = ui.createComponent("MyComponent", function()
	return function()
		return { Element:new({ content = "Hello World" }):wrap() }
	end
end, {})

local App = ui.createComponent("App", function()
	return MyComponent()
end, {})

describe("Fiber", function()
	local MAX_RECURSION_LIMIT = 20
	local current_recursion = 0

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

	it("renderiza MyComponent en una sola línea", function()
		local lines = render(App)
		eq({ "Hello World" }, lines:to_lines())
	end)

	it("renderiza List en dos líneas", function()
		local List = ui.createComponent("List", function()
			return function()
				return {
					Element:new({ content = "Línea 1" }):wrap(),
					Element:new({ content = "Línea 2" }):wrap(),
				}
			end
		end, {})
		local lines = render(List)
		eq({ "Línea 1", "Línea 2" }, lines:to_lines())
	end)

	it("soporta useState y re-renderiza al actualizar", function()
		-- componente con contador
		local count, setCount
		local Counter = ui.createComponent("Counter", function()
			return function()
				count, setCount = useState(0)
				return { Element:new({ content = "c:" .. count() }):wrap() }
			end
		end, {})

		-- render inicial
		local _, fiber = Counter()
		local rootFiber = fiber[1]
		workLoop(rootFiber)
		local buf1 = Buffer.new()
		commitWork(rootFiber, buf1)
		eq({ "c:0" }, buf1:to_lines())

		-- disparar actualización
		setCount(5)

		-- tras el setState, el propio hook habrá vuelto a renderizar
		local lines2 = rootFiber.lastRendered:to_lines()
		eq({ "c:5" }, lines2)
	end)
end)
