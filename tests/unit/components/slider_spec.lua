pcall(require, "luacov")

local eq = assert.are.same
local test_config = require("tests.config")

local Buffer = require("ascii-ui.buffer")
local Slider = require("ascii-ui.components.slider")

describe("SliderComponent", function()
	it("creates", function()
		Slider:new()
	end)

	it("renders", function()
		local slider = Slider:new()

		---@return string
		local line = function()
			return Buffer:new(unpack(slider:render(test_config))):to_string()
		end

		eq("+---------- 0%", line())

		slider:slide_to(10)
		eq("-+--------- 10%", line())

		slider:slide_to(50)
		eq("-----+----- 50%", line())

		slider:slide_to(90)
		eq("---------+- 90%", line())

		slider:slide_to(100)
		eq("----------+ 100%", line())
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

	it("does not go below zero", function()
		local slider = Slider:new()
		slider:move_left()
		eq(0, slider.value)
	end)

	it("does not go above 100", function()
		local slider = Slider:new()
		slider:slide_to(100)
		slider:move_right()
		eq(100, slider.value)
	end)
end)
