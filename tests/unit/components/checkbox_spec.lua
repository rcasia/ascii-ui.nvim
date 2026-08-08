pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Checkbox = require("ascii-ui.components.checkbox")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")

describe("checkbox", function()
	it("renders", function()
		local App = ui.createComponent("App", function()
			return Checkbox({ label = "some-label" })
		end)
		eq("[ ] some-label", fiber.render(App):get_buffer():to_string())

		local App2 = ui.createComponent("App", function()
			return Checkbox({ active = true, label = "some-other-label" })
		end)
		eq("[x] some-other-label", fiber.render(App2):get_buffer():to_string())
	end)
end)
