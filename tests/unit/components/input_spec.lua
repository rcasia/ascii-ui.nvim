pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Input = require("ascii-ui.components.input")
local testing = require("ascii-ui.testing")
local ui = require("ascii-ui")

describe("Input", function()
	it("renders", function()
		eq("", testing.render(Input):toSnapshot())
	end)

	it("renders with initial value", function()
		local initial_value = "hello world!"
		local App = ui.createComponent("App", function()
			return Input({ value = initial_value })
		end)

		eq(initial_value, testing.render(App):toSnapshot())
	end)
end)
