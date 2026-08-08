pcall(require, "luacov")
---@module "luassert"

local Box = require("ascii-ui.components.box")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")

local eq = assert.are.same

describe("renderer", function()
	describe("Box", function()
		it("should render a box", function()
			eq(
				--
				{
					"╭─────────────╮",
					"│             │",
					"╰─────────────╯",
				},
				fiber.render(Box):get_buffer():to_lines()
			)
		end)

		for _, box_props in ipairs({
			{ width = 10, height = 5 },
			{ width = 15, height = 3 },
			{ width = 20, height = 4 },
			{ width = 25, height = 10 },
		}) do
			it(("should render a box with width %s"):format(box_props), function()
				local App = ui.createComponent("App", function()
					return Box(box_props)
				end)

				local buffer = fiber.render(App):get_buffer()

				eq(box_props.width, buffer:width())
				eq(box_props.height, buffer:height())
			end)
		end

		it("should render a box with simple text", function()
			local App = ui.createComponent("App", function()
				return Box({ width = 17, height = 5, content = "Hello!" })
			end)

			eq({
				"╭───────────────╮",
				"│               │",
				"│     Hello!    │",
				"│               │",
				"╰───────────────╯",
			}, fiber.render(App):get_buffer():to_lines())

			local App2 = ui.createComponent("App", function()
				return Box({ width = 17, height = 5, content = "World!" })
			end)
			eq({
				"╭───────────────╮",
				"│               │",
				"│     World!    │",
				"│               │",
				"╰───────────────╯",
			}, fiber.render(App2):get_buffer():to_lines())
		end)
	end)
end)
