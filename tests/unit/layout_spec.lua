pcall(require, "luacov")
local DummyComponent = require("tests.util.dummy_functional_component")
local eq = assert.are.same

local Buffer = require("ascii-ui.buffer")
local Layout = require("ascii-ui.layout")

describe("Layout", function()
	it("render components in layout vertical by default", function()
		local layout = Layout(
			--
			DummyComponent(),
			DummyComponent()
		)

		eq({
			"dummy_render",
			"",
			"dummy_render",
		}, Buffer:new(unpack(layout())):to_lines())
	end)
end)
