pcall(require, "luacov")
---@module "luassert"

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

	describe("Box", function()
		it("should render a box", function()
			local box = Box({ __config = config })
			eq(
				--
				{
					"...............",
					".             .",
					"...............",
				},
				renderer:render(box()):to_lines()
			)
		end)

		for _, box_props in ipairs({
			{ width = 10, height = 5, __config = config },
			{ width = 15, height = 3, __config = config },
			{ width = 20, height = 4, __config = config },
			{ width = 25, height = 10, __config = config },
		}) do
			it(("should render a box with width %s"):format(box_props), function()
				local box = Box(box_props)

				local result = renderer:render(box()):to_lines()

				eq(box_props.width, result[1]:len())
				eq(box_props.height, #result)
			end)
		end

		it("should render a box with simple text", function()
			local box_hello = Box({ width = 17, height = 5, content = "Hello!", __config = config })

			eq({
				".................",
				".               .",
				".     Hello!    .",
				".               .",
				".................",
			}, renderer:render(box_hello()):to_lines())

			local box_world = Box({ width = 17, height = 5, content = "World!", __config = config })

			eq({
				".................",
				".               .",
				".     World!    .",
				".               .",
				".................",
			}, renderer:render(box_world()):to_lines())
		end)
	end)
end)
