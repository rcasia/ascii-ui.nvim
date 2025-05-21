pcall(require, "luacov")

local Element = require("ascii-ui.buffer.element")
local ui = require("ascii-ui")
local eq = assert.are.same

local Buffer = require("ascii-ui.buffer")
local Row = require("ascii-ui.layout.row")

describe("Row", function()
	local DummyComponent = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return function()
			return {
				Element:new(props.content):wrap(),
				Element:new(props.content):wrap(),
				Element:new("smol txt"):wrap(),
			}
		end
	end, { content = "string" })

	it("should render components in a row", function()
		local row = Row(
			--
			DummyComponent({ content = "component 1" }),
			DummyComponent({ content = "component 2" }),
			DummyComponent({ content = "component 3" })
		)

		eq({
			"component 1 component 2 component 3",
			"component 1 component 2 component 3",
			"smol txt    smol txt    smol txt",
		}, Buffer.new(unpack(row())):to_lines())
	end)
end)
