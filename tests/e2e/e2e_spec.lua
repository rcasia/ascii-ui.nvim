pcall(require, "luacov")
---@module "luassert"

local ui = require("ascii-ui")
local Options = require("ascii-ui.components.options")
local it = require("plenary.async.tests").it

local function feed(keys)
	vim.api.nvim_feedkeys(keys, "mtx", true)
end

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

		local bufnr = ui.mount(component)

		assert(vim.wait(1000, function()
			return buffer_contains(bufnr, "[x] book")
		end))

		vim.api.nvim_buf_delete(bufnr, {})

		local bufnr_2 = ui.mount(component)

		component:select_index(2)
		assert(vim.wait(1000, function()
			return buffer_contains(bufnr_2, "[x] pencil")
		end))
	end)

	describe("sliders", function()
		it("silders slide", function()
			local slider = ui.components.slider:new()

			local bufnr = ui.mount(slider)

			assert(vim.wait(1000, function()
				return buffer_contains(bufnr, "0%")
			end))

			feed("llllll")
			assert(vim.wait(1000, function()
				return buffer_contains(bufnr, "60%")
			end))

			feed("hhh")
			assert(vim.wait(1000, function()
				return buffer_contains(bufnr, "30%")
			end))
		end)
	end)
end)
