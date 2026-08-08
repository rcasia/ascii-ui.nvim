pcall(require, "luacov")

local eq = assert.are.same

local Slider = require("ascii-ui.components.slider")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")

describe("SliderComponent", function()
	---@return string
	local line = function(props)
		local App = ui.createComponent("App", function()
			return Slider(props)
		end)
		local buffer = fiber.render(App):get_buffer()
		return buffer:to_string()
	end

	it("renders", function()
		eq("●────────── 0%", line())

		eq("─●───────── 10%", line({ value = 10 }))

		eq("─────●───── 50%", line({ value = 50 }))

		eq("─────────●─ 90%", line({ value = 90 }))

		eq("──────────● 100%", line({ value = 100 }))
	end)

	it("renders slider with title", function()
		eq(
			[[Volume
●────────── 0%]],
			line({ title = "Volume" })
		)

		eq(
			[[Volume
──────────● 100%]],
			line({ title = "Volume", value = 100 })
		)
	end)
end)
