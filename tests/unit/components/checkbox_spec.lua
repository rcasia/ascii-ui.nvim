---@module "luassert"

local Checkbox = require("ascii-ui.components.checkbox")

describe("checkbox", function()
	it("is initialized as false by default", function()
		local checkbox = Checkbox:new()
		assert.is_false(checkbox:is_checked())
	end)

	it("it changes when toggle", function()
		local checkbox = Checkbox:new()
		checkbox:toggle()
		assert(checkbox:is_checked())
		checkbox:toggle()
		assert.is_false(checkbox:is_checked())
	end)

	it("can be initialized as true", function()
		local checkbox = Checkbox:new({ checked = true })
		assert(checkbox:is_checked())
	end)
end)
