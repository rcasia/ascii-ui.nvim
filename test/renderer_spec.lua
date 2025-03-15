local Checkbox = require("one-ui.components.checkbox")
local Box = require("one-ui.components.box")
local Renderer = require("one-ui.renderer")
local assert = require("luassert")
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

		it("should render a box with simple text", function()
			local box = Box:new()
			box:add_child("Hello!")

			eq(
				[[

┏━━━━━━━━━━━━━━━┓
┃     Hello!    ┃
┗━━━━━━━━━━━━━━━┛
]],
				renderer:render(box)
			)
		end)
	end)
end)
