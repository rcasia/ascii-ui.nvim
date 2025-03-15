require("luassert")

local Checkbox = require("one-ui.components.checkbox")
local Box = require("one-ui.components.box")
local Renderer = require("one-ui.renderer")
local eq = assert.are.same

describe("renderer", function()
	local renderer = Renderer:new()

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

┏━━━━━━━━━━━━━━━┓
┃               ┃
┗━━━━━━━━━━━━━━━┛
]],
				renderer:render(box)
			)
		end)

		for _, width in ipairs({ 10, 15, 20, 25 }) do
			it(("should render a box with width %d"):format(width), function()
				local box = Box:new({ width = width })

				local result = renderer:render(box)

				local top_left = result:find("┏")
				local top_right = result:find("┓")
				local units = string.len("━") -- because each character is counted in bytes
				local number_of_chars_on_top = top_right - top_left - units

				eq(width * units, number_of_chars_on_top)
			end)
		end

		it("should render a box with simple text", function()
			local box_hello = Box:new()
			box_hello:add_child("Hello!")

			eq(
				[[

┏━━━━━━━━━━━━━━━┓
┃     Hello!    ┃
┗━━━━━━━━━━━━━━━┛
]],
				renderer:render(box_hello)
			)

			local box_world = Box:new()
			box_world:add_child("World!")

			eq(
				[[

┏━━━━━━━━━━━━━━━┓
┃     World!    ┃
┗━━━━━━━━━━━━━━━┛
]],
				renderer:render(box_world)
			)
		end)
	end)
end)
