pcall(require, "luacov")
local assert = require("luassert")

local eq = assert.are.same

local Input = require("ascii-ui.components.input")
local renderer = require("ascii-ui.renderer"):new()
local ui = require("ascii-ui")

describe("Input", function()
	it("renders", function()
		eq("", renderer:render(Input):to_string())
	end)

	it("renders with initial value", function()
		local initial_value = "hello world!"
		local App = ui.createComponent("App", function()
			return Input({ value = initial_value })
		end)

		eq(initial_value, renderer:render(App):to_string())
	end)
end)
