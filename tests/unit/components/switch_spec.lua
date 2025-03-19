---@module "luassert"
local eq = assert.are.same

local Switch = require("ascii-ui.components.switch")

describe("Switch", function()
	it("should should be able to switch options", function()
		local options = { "on", "off" }
		local switch = Switch:new({ options = options })

		eq("off", switch:select_next())

		eq("on", switch:select_next())
	end)
end)
