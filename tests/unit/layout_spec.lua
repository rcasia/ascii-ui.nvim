local create_dummy_component = require("tests.util.dummy_component")
local eq = assert.are.same

local Layout = require("ascii-ui.layout")

describe("Layout", function()
	it("render components in layout vertical by default", function()
		local layout = Layout:new(
			--
			create_dummy_component(),
			create_dummy_component()
		)

		eq({
			"dummy_render",
			"",
			"dummy_render",
		}, layout:render():to_lines())
	end)
end)
