pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Checkbox = require("ascii-ui.components.checkbox")
local Renderer = require("ascii-ui.renderer")

describe("checkbox", function()
	local renderer = Renderer:new()

	it("renders", function()
		local checkbox = Checkbox({ label = "some-label" })
		eq("[ ] some-label", renderer:render(checkbox):to_string())

		local checkbox2 = Checkbox({ active = true, label = "some-other-label" })
		eq("[x] some-other-label", renderer:render(checkbox2):to_string())
	end)
end)
