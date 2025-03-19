---@module "luassert"

local Checkbox = require("ascii-ui.components.checkbox")
local Box = require("ascii-ui.components.box")
local Renderer = require("ascii-ui.renderer")
local eq = assert.are.same

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

	describe("checkbox", function()
		it("should render a checkbox", function()
			local checkbox = Checkbox:new()
			eq({ "[ ]" }, renderer:render(checkbox):to_lines())

			checkbox:toggle()
			eq({ "[x]" }, renderer:render(checkbox):to_lines())
		end)

		it("should render a checkbox with label", function()
			local checkbox = Checkbox:new({ checked = true, label = "test_label" })
			eq({ "[x] test_label" }, renderer:render(checkbox):to_lines())
		end)
	end)

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
				renderer:render(box)
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

				local result = renderer:render(box)

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
			}, renderer:render(box_hello))

			local box_world = Box:new({ width = 17, height = 5 })
			box_world:set_child("World!")

			eq({
				".................",
				".               .",
				".     World!    .",
				".               .",
				".................",
			}, renderer:render(box_world))
		end)
	end)
end)
