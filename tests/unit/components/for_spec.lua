pcall(require, "luacov")
local assert = require("luassert")

local eq = assert.are.same

local Element = require("ascii-ui.buffer.element")
local For = require("ascii-ui.components.for")
local renderer = require("ascii-ui.renderer"):new()
local ui = require("ascii-ui")

describe("For", function()
	local DummyComponent = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return function()
			return { Element:new(props.content):wrap() }
		end
	end, { content = "string" })

	it("renders a list of components based on a list of props", function()
		local App = ui.createComponent("App", function()
			return For({
				props = { { content = "t-shirt 1" }, { content = "t-shirt 2" } },
				component = DummyComponent,
			})
		end)

		eq({ "t-shirt 1", "t-shirt 2" }, renderer:render(App):to_lines())
	end)

	it("renders a list of components based on a list of items, transformed to props", function()
		local App = ui.createComponent("App", function()
			return For({
				items = { "t-shirt 1", "t-shirt 2" },
				transform = function(item)
					return { content = item }
				end,
				component = DummyComponent,
			})
		end)

		eq({ "t-shirt 1", "t-shirt 2" }, renderer:render(App):to_lines())
	end)
end)
