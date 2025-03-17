require("luassert")
local ui = require("ascii-ui")
local Box = require("ascii-ui.components.box")

---@param bufnr integer
---@param pattern string
---@return boolean
local function buffer_contains(bufnr, pattern)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local content_str = vim.iter(lines):join("")

	return string.find(content_str, pattern) ~= nil
end

describe("ascii-ui", function()
	it("ui.render() should render component", function()
		local expected_msg = "Hello World!"
		local component = Box:new()
		component:set_child(expected_msg)

		local bufnr = ui.render(component)

		assert(bufnr)
		assert(buffer_contains(bufnr, expected_msg))
	end)
end)
