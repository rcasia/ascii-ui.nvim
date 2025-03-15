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

		for _, width in ipairs({ 10, 15, 20, 25 }) do
			-- TODO: add height
			it(("should render a box with width %d"):format(width), function()
				local box = Box:new({ width = width })

				local result = renderer:render(box)

				local top_left_pos = string.find(result, "q")
				local top_right_pos = string.find(result, "p")

				print(result)
				eq(width, top_right_pos - top_left_pos + 1)
			end)
		end

		it("should render a box with simple text", function()
			local box_hello = Box:new({ width = 17 })
			box_hello:add_child("Hello!")

			eq(
				[[

q...............p
.     Hello!    .
d...............b
]],
				renderer:render(box_hello)
			)

			local box_world = Box:new({ width = 17 })
			box_world:add_child("World!")

			eq(
				[[

q...............p
.     World!    .
d...............b
]],
				renderer:render(box_world)
			)
		end)
	end)
end)
