local Window = require("ascii-ui.window")

local M = {}

--- Creates a fullscreen window that takes up the entire editor.
---@tag ascii-ui.window.fullscreen.create()
---
---@param opts? ascii-ui.WindowOpts
---@return ascii-ui.Window
function M.create(opts)
	opts = opts or {}

	local window = Window.new(opts)

	-- Mark this as a fullscreen window (so update() knows not to resize)
	window.is_fullscreen = true

	-- Override the open method to create a fullscreen window
	window.open = function(self)
		-- Create a new unlisted, scratch buffer
		local buf = vim.api.nvim_create_buf(false, true)

		-- Get full editor dimensions
		local editor_width = vim.o.columns
		local editor_height = vim.o.lines - vim.o.cmdheight - 1 -- Account for command line and statusline

		-- Open fullscreen floating window
		local win = vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			width = editor_width,
			height = editor_height,
			row = 0,
			col = 0,
			style = "minimal",
		})

		vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

		self.winid = win
		self.bufnr = buf

		local initialize_window_keymaps = require("ascii-ui.window.keymaps")
		initialize_window_keymaps(self)
	end

	return window
end

return M
