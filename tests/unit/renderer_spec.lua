pcall(require, "luacov")
---@module "luassert"

local Renderer = require("ascii-ui.renderer")
local eq = assert.are.same

local Column = require("ascii-ui.layout.column")
local DummyComponent = require("tests.util.dummy_functional_component")
local Row = require("ascii-ui.layout.row")

describe("renderer", function()
	local config = {
		characters = {
			top_left = ".",
			top_right = ".",
			bottom_left = ".",
			bottom_right = ".",
			horizontal = ".",
			vertical = ".",
		},
	}
	local renderer = Renderer:new(config)

	it("should render a component", function()
		local component = DummyComponent()
		eq({ "dummy_render" }, renderer:render(component):to_lines())
	end)

	it("should render a custom component", function()
		local App = function()
			return Column(DummyComponent())
		end
		eq({ "dummy_render" }, renderer:render(App):to_lines())
	end)

	it("puts config in closure function first param", function()
		local actual_config
		local ExampleComponent = function()
			return function(c)
				actual_config = c
				return {}
			end
		end
		local App = function()
			return Column(Row(ExampleComponent()))
		end
		renderer:render(App)

		eq(config, actual_config)
	end)
end)
