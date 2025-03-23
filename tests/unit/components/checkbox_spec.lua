pcall(require, "luacov")
---@module "luassert"
local eq = assert.are.same

local Checkbox = require("ascii-ui.components.checkbox")

describe("checkbox", function()
	describe("component", function()
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

	describe("render()", function()
		it("renders", function()
			local checkbox = Checkbox:new({ label = "some-label" })
			local bline_a = checkbox:render()[1]
			eq("[ ] some-label", bline_a:to_string())

			checkbox:toggle()

			local bline_b = checkbox:render()[1]
			eq("[x] some-label", bline_b:to_string())
		end)
	end)
end)
