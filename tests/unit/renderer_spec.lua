pcall(require, "luacov")
---@module "luassert"

local Box = require("ascii-ui.components.box")
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

	-- TODO: change responsability to box_spec.lua
	describe("box", function()
		it("should render a box", function()
			local box = Box:new()

			eq(
				--
				{
					"...............",
					".             .",
					"...............",
				},
				renderer:render(box):to_lines()
			)
		end)

		for _, box_props in ipairs({
			{ width = 10, height = 5 },
			{ width = 15, height = 3 },
			{ width = 20, height = 4 },
			{ width = 25, height = 10 },
		}) do
			it(("should render a box with width %s"):format(box_props), function()
				local box = Box:new(box_props)

				local result = renderer:render(box):to_lines()

				eq(box_props.width, result[1]:len())
				eq(box_props.height, #result)
			end)
		end

		it("should render a box with simple text", function()
			local box_hello = Box:new({ width = 17, height = 5 })
			box_hello:set_child("Hello!")

			eq({
				".................",
				".               .",
				".     Hello!    .",
				".               .",
				".................",
			}, renderer:render(box_hello):to_lines())

			local box_world = Box:new({ width = 17, height = 5 })
			box_world:set_child("World!")

			eq({
				".................",
				".               .",
				".     World!    .",
				".               .",
				".................",
			}, renderer:render(box_world):to_lines())
		end)
	end)
end)
