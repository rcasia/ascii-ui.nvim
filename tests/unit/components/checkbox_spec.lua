pcall(require, "luacov")
local assert = require("luassert")

local eq = assert.are.same

local Checkbox = require("ascii-ui.components.checkbox")
local Renderer = require("ascii-ui.renderer")
local ui = require("ascii-ui")

describe("checkbox", function()
	local renderer = Renderer:new()

	it("renders", function()
		local App = ui.createComponent("App", function()
			return Checkbox({ label = "some-label" })
		end)
		eq("[ ] some-label", renderer:render(App):to_string())

		local App2 = ui.createComponent("App", function()
			return Checkbox({ active = true, label = "some-other-label" })
		end)
		eq("[x] some-other-label", renderer:render(App2):to_string())
	end)
end)
