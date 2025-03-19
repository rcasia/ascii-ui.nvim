---@module "luassert"
local eq = assert.are.same

local Options = require("ascii-ui.components.options")

describe("Options", function()
	it("should should be able to cycle options", function()
		local options = { "apple", "banana", "mango" }
		local switch = Options:new({ options = options })

		eq("banana", switch:select_next())
		eq("mango", switch:select_next())
		eq("apple", switch:select_next())
	end)
end)
