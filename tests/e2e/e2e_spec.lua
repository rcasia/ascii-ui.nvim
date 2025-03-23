pcall(require, "luacov")
---@module "luassert"

local ui = require("ascii-ui")
local Options = require("ascii-ui.components.options")

---@param bufnr integer
---@param pattern string
---@return boolean
local function buffer_contains(bufnr, pattern)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local content_str = vim.iter(lines):join("\n")

	print(content_str)
	print("")
	return string.find(content_str, pattern, 1, true) ~= nil
end

describe("ascii-ui", function()
	it("should open close and open again with out problems", function()
		local component = Options:new({ options = {
			"book",
			"pencil",
			"rubber",
		} })

		local bufnr = ui.render(component)

		assert(vim.wait(1000, function()
			return buffer_contains(bufnr, "[x] book")
		end))

		vim.api.nvim_buf_delete(bufnr, {})

		local bufnr_2 = ui.render(component)

		component:select_index(2)
		assert(vim.wait(1000, function()
			return buffer_contains(bufnr_2, "[x] pencil")
		end))
	end)
end)
