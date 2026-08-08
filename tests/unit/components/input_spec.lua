pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Input = require("ascii-ui.components.input")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")

describe("Input", function()
	it("renders", function()
		eq("", fiber.render(Input):get_buffer():to_string())
	end)

	it("renders with initial value", function()
		local initial_value = "hello world!"
		local App = ui.createComponent("App", function()
			return Input({ value = initial_value })
		end)

		eq(initial_value, fiber.render(App):get_buffer():to_string())
	end)
end)
