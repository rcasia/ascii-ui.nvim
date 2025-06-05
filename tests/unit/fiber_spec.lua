pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local logger = require("ascii-ui.logger")

local Element = require("ascii-ui.buffer.element")
local ui = require("ascii-ui")

--- @class ascii-ui.FiberNode
--- @field type "Root" | string
--- @field closure fun(): function, ascii-ui.FiberNode[]
--- @field output ascii-ui.FiberNode[] | nil
--- @field child any | nil

local MyComponent = ui.createComponent("MyComponent", function()
	return function()
		return { Element:new({ content = "Hello World" }):wrap() }
	end
end, {})

local App = ui.createComponent("App", function()
	return MyComponent()
end, {})

describe("Fiber", function()
	local function reconcileChildren(parent, output)
		if type(output) == "table" and output.closure then
			parent.child = output
			output.parent = parent
		end
	end

	--- @param fiber ascii-ui.FiberNode
	local function performUnitOfWork(fiber)
		logger.debug(vim.inspect(fiber))
		if fiber.closure then
			local _, result = fiber.closure()
			fiber.output = result
			reconcileChildren(fiber, result)
		end
	end

	it("renders a simple component that returns static lines", function()
		local _, rootFiber = App() --- @cast rootFiber ascii-ui.FiberNode

		performUnitOfWork(rootFiber)

		eq("App", rootFiber.type)
		local childFiber = rootFiber.child
		eq("MyComponent", childFiber.type)

		performUnitOfWork(childFiber)

		print(vim.inspect(rootFiber))
	end)
end)
