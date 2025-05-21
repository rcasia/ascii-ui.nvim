pcall(require, "luacov")

local DummyComponent = require("tests.util.dummy_functional_component")
local eq = assert.are.same

local Buffer = require("ascii-ui.buffer")
local Row = require("ascii-ui.layout.row")

describe("Row", function()
	it("should render a components in a row", function()
		local row = Row(
			--
			DummyComponent(),
			DummyComponent()
		)

		eq({
			"dummy_render dummy_render",
		}, Buffer:new(unpack(row())):to_lines())
	end)
end)
