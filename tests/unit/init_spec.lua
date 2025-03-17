require("luassert")
local ui = require("ascii-ui")
local Box = require("ascii-ui.components.box")

local eq = assert.are.same

describe("ascii-ui", function()
	it("ui.render() should render component", function()
		local expected_msg = "Hello World!"
		local component = Box:new()
		component:set_child(expected_msg)

		local bufnr = ui.render(component)

		assert(bufnr)
		-- read the buf content
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local lines_str = vim.iter(lines):join("")

		assert(string.find(lines_str, expected_msg))
	end)
end)
