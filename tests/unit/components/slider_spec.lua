pcall(require, "luacov")

local assert = require("luassert")
local eq = assert.are.same
local test_config = require("tests.config")

local Renderer = require("ascii-ui.renderer")
local Slider = require("ascii-ui.components.slider")
local ui = require("ascii-ui")

describe("SliderComponent", function()
	local renderer = Renderer:new(test_config)

	---@return string
	local line = function(props)
		local App = ui.createComponent("App", function()
			return Slider(props)
		end)
		local buffer = renderer:render(App)
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
