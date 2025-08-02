pcall(require, "luacov")
---@module "luassert"

local ui = require("ascii-ui")
local it = require("plenary.async.tests").it
local Bufferline = require("ascii-ui.buffer.bufferline")
local Cursor = require("ascii-ui.cursor")
local Element = require("ascii-ui.buffer.element")

local function feed(keys)
	vim.api.nvim_feedkeys(keys, "mtx", true)
end

--- @param line integer
--- @param col? integer
local function cursor_is_in(line, col)
	return vim.wait(400, function()
		local cursor = Cursor.current_position()
		print("cursor in" .. vim.inspect(cursor))
		if type(col) == "nil" then
			return cursor.line == line
		end

		return cursor.line == line and cursor.col == col
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

describe("Focusable", function()
	it("when user moves cursor jumps to focusables (UP and DOWN)", function()
		local non_focusable_line = Element:new({ content = "Not focusable" }):wrap()
		local focusable_line = Element:new({ content = "Focusable", is_focusable = true }):wrap()
		local App = ui.createComponent("App", function()
			return {

				Element:new({ content = "Not focusable" }):wrap(),
				Element:new({ content = "Focusable", is_focusable = true }):wrap(),
				non_focusable_line:append(focusable_line),
				Element:new({ content = "Not focusable" }):wrap(),
				Element:new({ content = "Focusable", is_focusable = true }):wrap(),
				Element:new({ content = "Not focusable" }):wrap(),
			}
		end)

		local bufnr = ui.mount(App)

		assert(buffer_contains(bufnr, "Focusable"))
		assert(cursor_is_in(1, 0))

		feed("j")
		assert(cursor_is_in(2, 0))

		feed("j")
		assert(cursor_is_in(3, 13))

		feed("j")
		assert(cursor_is_in(5, 0))

		feed("k")
		assert(cursor_is_in(3, 13))

		feed("k")
		assert(cursor_is_in(2, 0))

		feed("k")
		assert(cursor_is_in(2, 0))
	end)

	it("when user moves cursor jumps to focusables (LEFT and RIGHT)", function()
		local unfocusable = Element:new({ content = "o" })
		local focusable = Element:new({ content = "x", is_focusable = true })
		local App = ui.createComponent("App", function()
			return {
				Bufferline.new(focusable, unfocusable, focusable, unfocusable, focusable),
			}
		end)

		local bufnr = ui.mount(App)

		assert(buffer_contains(bufnr, "xoxox"), "not contains")
		assert(cursor_is_in(1, 0), "1,0")

		feed("l")
		assert(cursor_is_in(1, 2), "1,2")

		feed("l")
		assert(cursor_is_in(1, 4), "1,4")

		feed("h")
		assert(cursor_is_in(1, 2), "1,2 back")

		feed("h")
		assert(cursor_is_in(1, 0), "1,0 back")
	end)
end)
