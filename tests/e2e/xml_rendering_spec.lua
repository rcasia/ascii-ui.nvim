pcall(require, "luacov")
local assert = require("luassert")

local ui = require("ascii-ui")
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
	it("renders a clickable button with XML", function()
		-- local function App()
		local App = ui.createComponent("App", function()
			local message, set_message = ui.hooks.useState("Hello World")
			local ref = ui.hooks.useFunctionRegistry(function()
				set_message("Button Clicked!")
			end)

			return ([[

		<Column>
			<Paragraph content="%s" />
			<Button label="Click me" on_press="%s" />
		</Column>

		]]):format(message, ref)
		end)

		local bufnr = ui.mount(App)

		assert(buffer_contains(bufnr, "Hello World"))

		feed("j") -- move cursor down to the button
		assert(cursor_is_in_line(2)) -- ensure cursor is on the button line
		vim.schedule(function()
			local enter = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
			feed(enter) -- simulate pressing Enter on the button
		end)

		assert(buffer_contains(bufnr, "Button Clicked!"))
	end)
end)
