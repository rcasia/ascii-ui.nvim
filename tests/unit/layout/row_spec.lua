pcall(require, "luacov")

local eq = assert.are.same

local Element = require("ascii-ui.buffer.element")
local renderer = require("ascii-ui.renderer"):new()
local ui = require("ascii-ui")

local Row = require("ascii-ui.layout.row")

describe("Row", function()
	local DummyComponent = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return function()
			return {
				Element:new(props.content):wrap(),
				Element:new(props.content):wrap(),
				Element:new("smol txt"):wrap(),
			}
		end
	end, { content = "string" })

	it("should render components in a row", function()
		local App = ui.createComponent("DummyApp", function()
			return Row(
				DummyComponent({ content = "component 1" }),
				DummyComponent({ content = "component 2" }),
				DummyComponent({ content = "component 3" })
			)
		end)

		eq({
			"component 1 component 2 component 3",
			"component 1 component 2 component 3",
			"smol txt    smol txt    smol txt",
		}, renderer:render(App):to_lines())
	end)

	local AnotherComponent = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return function()
			return vim.iter(vim.fn.range(1, props.times))
				:map(function()
					return Element:new(props.content):wrap()
				end)
				:totable()
		end
	end, { content = "string", times = "number" })

	it("should render components respecting the empty space on the left", function()
		local App = ui.createComponent("DummyApp", function()
			return Row(
				AnotherComponent({ content = "component 1", times = 1 }),
				AnotherComponent({ content = "component 2", times = 2 }),
				AnotherComponent({ content = "component 3", times = 3 })
			)
		end)

		eq({
			"component 1 component 2 component 3",
			"            component 2 component 3",
			"                        component 3",
		}, renderer:render(App):to_lines())
	end)
end)
