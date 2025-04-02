pcall(require, "luacov")

local eq = assert.are.same

local Buffer = require("ascii-ui.buffer.buffer")
local Slider = require("ascii-ui.components.slider")

describe("SliderComponent", function()
	it("creates", function()
		Slider:new()
	end)

	it("renders", function()
		local slider = Slider:new()

		---@return string
		local line = function()
			return Buffer:new(unpack(slider:render())):to_string()
		end

		eq("+---------", line())

		slider:slide_to(90)
		eq("--------+-", line())

		slider:slide_to(50)
		eq("----+-----", line())

		slider:slide_to(100)
		eq("---------+", line())
	end)

	it("increments ten on move_right", function()
		local slider = Slider:new()
		slider:slide_to(50)
		slider:move_right()
		eq(60, slider.value)
	end)

	it("decrements ten on move_left", function()
		local slider = Slider:new()
		slider:slide_to(50)
		slider:move_left()
		eq(40, slider.value)
	end)
end)
