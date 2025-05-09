pcall(require, "luacov")
---@module "luassert"

local Renderer = require("ascii-ui.renderer")
local eq = assert.are.same

local create_dummy_component = require("tests.util.dummy_component")
local DummyComponent = require("tests.util.dummy_functional_component")
local Layout = require("ascii-ui.layout")

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
		local component = create_dummy_component()
		eq({ "dummy_render" }, renderer:render(component):to_lines())
	end)

	it("should render a custom component", function()
		local App = function()
			return Layout(DummyComponent())
		end
		eq({ "dummy_render 1" }, renderer:render(App()):to_lines())
		eq({ "dummy_render 2" }, renderer:render(App()):to_lines())
	end)
end)
