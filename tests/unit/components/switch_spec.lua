---@module "luassert"
local eq = assert.are.same

local Switch = require("ascii-ui.components.switch")

describe("Switch", function()
	it("should create", function()
		local switch = Switch:new()
	end)
end)
