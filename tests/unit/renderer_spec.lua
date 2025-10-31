pcall(require, "luacov")
---@module "luassert"

local Renderer = require("ascii-ui.renderer")
local eq = require("tests.util.eq")

local DummyComponent = require("tests.util.dummy_functional_component")
local ui = require("ascii-ui")

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
		eq({ "dummy_render" }, renderer:render(DummyComponent):to_lines())
	end)

	it("should render a custom component", function()
		local App = ui.createComponent("App", function()
			-- return Column(DummyComponent())
			return DummyComponent()
		end)
		eq({ "dummy_render" }, renderer:render(App):to_lines())
	end)
end)
