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
--- @field child ascii-ui.FiberNode | nil
--- @field sibling ascii-ui.FiberNode | nil

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
			if i == 1 then
				parent.child = node
			else
				prevSibling.sibling = node
			end
			prevSibling = node
		end
	end

	--- @param fiber ascii-ui.FiberNode
	local function performUnitOfWork(fiber)
		assert(fiber, "Fiber cannot be nil")
		if fiber.closure then
			local lines, result = fiber.closure()
			fiber.output = result or lines()
			reconcileChildren(fiber, fiber.output)
		else
			error("fiber.closure cannot be nil on: " .. vim.inspect(fiber))
		end
	end

	--- @param fiber ascii-ui.FiberNode
	--- @param buffer ascii-ui.Buffer
	local function commitWork(fiber, buffer)
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

	it("renders a simple component that returns static lines", function()
		local _, fiber = App() --- @cast fiber ascii-ui.FiberNode[]

		local rootFiber = fiber[1]
		performUnitOfWork(rootFiber)

		eq("App", rootFiber.type)
		local childFiber = assert(rootFiber.child, vim.inspect(rootFiber))
		eq("MyComponent", childFiber.type)

		performUnitOfWork(childFiber)

		local buffer = Buffer.new()
		commitWork(rootFiber, buffer)
		eq({ "Hello World" }, buffer:to_lines())
	end)

	it("hace commit de todas las líneas al buffer", function()
		-- montamos un componente que devuelva dos líneas
		local List = ui.createComponent("List", function()
			return function()
				return {
					Element:new({ content = "Línea 1" }):wrap(),
					Element:new({ content = "Línea 2" }):wrap(),
				}
			end
		end, {})

		local _, fiber = List() --- @cast fiber ascii-ui.FiberNode[]
		local root = fiber[1]
		performUnitOfWork(root)
		print(vim.inspect(root))

		-- ahora hacemos commit al buffer simulado
		local buffer = Buffer.new()
		commitWork(root, buffer)
		eq({ "Línea 1", "Línea 2" }, buffer:to_lines())
	end)
end)
