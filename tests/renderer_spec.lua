require("luassert")

local Checkbox = require("one-ui.components.checkbox")
local Box = require("one-ui.components.box")
local Renderer = require("one-ui.renderer")
local eq = assert.are.same

describe("renderer", function()
	local config = {
		characters = {
			top_left = "q",
			top_right = "p",
			bottom_left = "d",
			bottom_right = "b",
			horizontal = ".",
			vertical = ".",
		},
	}
	local renderer = Renderer:new(config)

	describe("checkbox", function()
		it("should render a checkbox", function()
			local checkbox = Checkbox:new()
			eq("[ ]", renderer:render(checkbox))

			checkbox:toggle()
			eq("[X]", renderer:render(checkbox))
		end)
	end)

	describe("box", function()
		it("should render a box", function()
			local box = Box:new()

			eq(
				[[

q.............p
.             .
d.............b
]],
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

				local top_left_pos = string.find(result, "q")
				local top_right_pos = string.find(result, "p")

				local actual_height = #vim.split(result, "\n") - 2 -- remove the first and last line

				eq(box_props.width, top_right_pos - top_left_pos + 1)
				eq(box_props.height, actual_height)
			end)
		end

		it("should render a box with simple text", function()
			local box_hello = Box:new({ width = 17, height = 5 })
			box_hello:set_child("Hello!")

			eq(
				[[

q...............p
.               .
.     Hello!    .
.               .
d...............b
]],
				renderer:render(box_hello)
			)

			local box_world = Box:new({ width = 17, height = 5 })
			box_world:set_child("World!")

			eq(
				[[

q...............p
.               .
.     World!    .
.               .
d...............b
]],
				renderer:render(box_world)
			)
		end)
	end)
end)
