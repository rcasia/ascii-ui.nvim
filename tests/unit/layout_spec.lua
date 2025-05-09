pcall(require, "luacov")
local create_dummy_component = require("tests.util.dummy_component")
local DummyComponent = require("tests.util.dummy_functional_component")
local eq = assert.are.same

local Layout = require("ascii-ui.layout")
local Buffer = require("ascii-ui.buffer")

describe("Layout", function()
	it("render components in layout vertical by default", function()
		local layout = Layout.fun(
			--
			DummyComponent(),
			DummyComponent()
		)

		eq({
			"dummy_render 1",
			"",
			"dummy_render 2",
		}, Buffer:new(unpack(layout())):to_lines())
	end)

	it("subscribes and destroys recursively", function()
		local component = create_dummy_component()
		local layout = Layout:new(component)

		local interactions_count = 0
		layout:on_change(function()
			interactions_count = interactions_count + 1
		end)

		eq(0, interactions_count)

		---@diagnostic disable-next-line: inject-field
		component.unchecked_field = 1
		eq(1, interactions_count)

		layout:destroy()

		---@diagnostic disable-next-line: inject-field
		component.unchecked_field = 2
		eq(1, interactions_count)
	end)
end)
