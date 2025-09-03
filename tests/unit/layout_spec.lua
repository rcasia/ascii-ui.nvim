pcall(require, "luacov")
local DummyComponent = require("tests.util.dummy_functional_component")
local assert = require("luassert")
local eq = assert.are.same

local Column = require("ascii-ui.layout.column")
local renderer = require("ascii-ui.renderer"):new()
local ui = require("ascii-ui")

describe("Column", function()
	it("render components in layout vertical by default", function()
		local App = ui.createComponent("App", function()
			return function()
				return Column(
					--
					DummyComponent(),
					DummyComponent()
				)
			end
		end)

		eq({
			"dummy_render",
			"",
			"dummy_render",
		}, renderer:render(App):to_lines())
	end)
end)
