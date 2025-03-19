---@module "luassert"
local eq = assert.are.same

local Options = require("ascii-ui.components.options")

describe("Options", function()
	it("cycles options", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Options:new({ options = option_names })

		eq("banana", options:select_next())
		eq("mango", options:select_next())
		eq("apple", options:select_next())
	end)

	it("selects by 1-based index", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Options:new({ options = option_names })

		eq("apple", options:select_index(1))
		eq("banana", options:select_index(2))
		eq("mango", options:select_index(3))
	end)
end)
