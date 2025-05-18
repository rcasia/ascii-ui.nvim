pcall(require, "luacov")
---@module "luassert"

local Options = require("ascii-ui.components.select")
local ui = require("ascii-ui")
local it = require("plenary.async.tests").it
local Paragraph = ui.components.Paragraph
local Slider = ui.components.Slider
local useState = ui.hooks.useState
local function feed(keys)
	vim.api.nvim_feedkeys(keys, "mtx", true)
end

local function cursor_is_in_line(number)
	return vim.wait(1, function()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local line = cursor[1]

		return line == number
	end)
end

---@param bufnr integer
---@param pattern string
---@return boolean
local function buffer_contains(bufnr, pattern)
	return vim.wait(1000, function()
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local content_str = vim.iter(lines):join("\n")

		print(content_str)
		print("")
		return string.find(content_str, pattern, 1, true) ~= nil
	end)
end

describe("ascii-ui", function()
	it("should open close and open again with out problems", function()
		local component = Options({ options = {
			"book",
			"pencil",
			"rubber",
		} })

		local bufnr = ui.mount(component)

		assert(buffer_contains(bufnr, "[x] book"))

		vim.api.nvim_buf_delete(bufnr, {})

		-- TODO: check second option can be selected
		-- assert(buffer_contains(bufnr_2, "[x] pencil"))
	end)

	describe("sliders", function()
		it("silders slide", function()
			local bufnr = ui.mount(ui.layout(
				--
				Slider(),
				Slider()
			))

			assert(buffer_contains(bufnr, "0%"))

			feed("llllll")
			assert(buffer_contains(bufnr, "60%"))

			feed("hhh")
			assert(buffer_contains(bufnr, "30%"))

			feed("j")
			assert(cursor_is_in_line(3))

			feed("ll")
			assert(buffer_contains(bufnr, "20%"))

			feed("ll")
			assert(buffer_contains(bufnr, "40%"))
		end)

		it("functional", function()
			local content, setContent = useState("hola mundo")

			local bufnr = ui.mount(Paragraph({ content = content }))
			assert(buffer_contains(bufnr, "hola mundo"))

			setContent("lemon juice")
			assert(buffer_contains(bufnr, "lemon juice"))
		end)
	end)
end)
