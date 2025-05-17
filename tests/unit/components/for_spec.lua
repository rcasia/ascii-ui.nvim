pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local ui = require("ascii-ui")
local Buffer = require("ascii-ui.buffer")
local Element = require("ascii-ui.buffer.element")
local For = require("ascii-ui.components.for")

describe("For", function()
	local DummyComponent = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return function()
			return { Element:new(props.content):wrap() }
		end
	end)

	it("renders child component when condition is true", function()
		local component_closure =
			For({ props = { { content = "t-shirt 1" }, { content = "t-shirt 2" } }, component = DummyComponent })

		---@return string
		local lines = function()
			return Buffer:new(unpack(component_closure())):to_string()
		end
		eq(
			[[t-shirt 1
t-shirt 2]],
			lines()
		)
	end)
end)
