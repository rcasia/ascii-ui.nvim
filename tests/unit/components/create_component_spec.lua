pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local Buffer = require("ascii-ui.buffer")
local Element = require("ascii-ui.buffer.element")
local ui = require("ascii-ui")

describe("ComponentCreator.createComponent", function()
	local DummyComponent = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return function()
			return { Element:new({ content = props.content, interactions = { on_select = props.on_select } }):wrap() }
		end
	end, { content = "string", on_select = "function" })

	---@param closure function
	---@return string
	local lines = function(closure)
		return Buffer.new(unpack(closure())):to_string()
	end

	it("creates a component that can take props either as function or its simple type", function()
		local component_closure1 = DummyComponent({ content = "t-shirt" })
		local component_closure2 = DummyComponent({
			content = function()
				return "t-shirt"
			end,
		})

		eq(lines(component_closure1), lines(component_closure2))
	end)

	it("creates a component that can take functions and are not called on definition", function()
		local invocations = 0
		local component_closure1 = DummyComponent({ content = "t-shirt" })
		local component_closure2 = DummyComponent({
			content = function()
				return "t-shirt"
			end,
			on_select = function()
				invocations = invocations + 1
			end,
		})

		eq(lines(component_closure1), lines(component_closure2))
		eq(0, invocations)
	end)

	it("validates props on definition call", function()
		assert.error(function()
			DummyComponent({ content = 2 })
		end, "Invalid prop type for 'content'. Expected 'string', got 'number'.")
	end)

	it("accepts plain function", function()
		local MyComponent = ui.createComponent("MyComponent", function()
			return {
				Element:new({ content = "Hello World" }):wrap(),
			}
		end)

		local closure, _ = MyComponent()
		eq("Hello World", lines(closure))
	end)
end)
