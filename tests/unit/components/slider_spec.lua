pcall(require, "luacov")

local eq = assert.are.same
local test_config = require("tests.config")

local Buffer = require("ascii-ui.buffer")
local Slider = require("ascii-ui.components.slider")

describe("SliderComponent", function()
	---@return string
	local line = function(props)
		return Buffer.new(unpack(Slider(props)())):to_string()
	end

	it("renders", function()
		eq("+---------- 0%", line({ config = test_config }))

		eq("-+--------- 10%", line({ value = 10, config = test_config }))

		eq("-----+----- 50%", line({ value = 50, config = test_config }))

		eq("---------+- 90%", line({ value = 90, config = test_config }))

		eq("----------+ 100%", line({ value = 100, config = test_config }))
	end)

	it("renders slider with title", function()
		eq(
			[[Volume
+---------- 0%]],
			line({ title = "Volume", config = test_config })
		)

		eq(
			[[Volume
----------+ 100%]],
			line({ title = "Volume", value = 100, config = test_config })
		)
	end)
end)
