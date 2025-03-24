pcall(require, "luacov")

local eq = assert.are.same

local Slider = require("ascii-ui.components.slider")

describe("SliderComponent", function()
	it("creates", function()
		Slider:new()
	end)

	it("renders", function()
		local slider = Slider:new()

		local line = slider:render()[1]
		eq("+---------", line:to_string())

		slider:slide_to(90)
		eq("--------+-", slider:render()[1]:to_string())

		slider:slide_to(50)
		eq("----+-----", slider:render()[1]:to_string())

		slider:slide_to(100)
		eq("---------+", slider:render()[1]:to_string())
	end)
end)
