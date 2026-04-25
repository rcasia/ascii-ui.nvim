pcall(require, "luacov")
---@module "luassert"

local renderer = require("ascii-ui.renderer"):new()
local ui = require("ascii-ui")
local Segment = require("ascii-ui.buffer.segment")
local Row = require("ascii-ui.components.row")

describe("Row", function()
	local DummyComponent = ui.createComponent("DummyRowComponent", function(props)
		return vim
			.iter(vim.split(props.content, ""))
			:map(function(char)
				return Segment:new(char):wrap()
			end)
			:totable()
	end, { content = "string" })

	it("should render components side by side", function()
		local App = ui.createComponent("App", function()
			return Row({
				children = {
					DummyComponent({ content = "abc" }),
					DummyComponent({ content = "def" }),
				},
			})
		end)

		assert.are.same({ "abcdef" }, renderer:render(App):to_lines())
	end)

	local RepeatComponent = ui.createComponent("RepeatComponent", function(props)
		return vim
			.iter(vim.fn.range(props.times))
			:map(function(_)
				return Segment:new(props.content):wrap()
				end)
			:totable()
	end, { content = "string", times = "number" })

	it("should render components respecting the empty space on the left", function()
		local App = ui.createComponent("App2", function()
			return Row({
				children = {
					RepeatComponent({ content = "component 1", times = 1 }),
					RepeatComponent({ content = "component 2", times = 2 }),
					RepeatComponent({ content = "component 3", times = 3 }),
				},
			})
		end)

		assert.are.same({
			"component 1component 2component 2component 3component 3component 3",
		}, renderer:render(App):to_lines())
	end)
end)
