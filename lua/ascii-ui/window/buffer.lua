local Window = require("ascii-ui.window")

---@class ascii-ui.BufferWindowOpts : ascii-ui.WindowOpts
---@field bufnr integer The buffer number to render into

local M = {}

--- Creates a window wrapper for an existing buffer provided by the user.
---@tag ascii-ui.window.buffer.create()
---
---@param opts ascii-ui.BufferWindowOpts
---@return ascii-ui.Window
function M.create(opts)
	if not opts or not opts.bufnr then
		error("bufnr is required for buffer window")
	end

	local window = Window.new(opts)

	-- Override the open method to use existing buffer
	window.open = function(self)
		-- Use the provided buffer
		local buf = opts.bufnr

		-- Check if buffer exists and is valid
		if not vim.api.nvim_buf_is_valid(buf) then
			error("Invalid buffer: " .. buf)
		end

		-- Find or create a window for this buffer
		local wins = vim.fn.win_findbuf(buf)
		local win

		if #wins > 0 then
			-- Use existing window
			win = wins[1]
		else
			-- Create new window for the buffer
			vim.cmd("split")
			win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(win, buf)
		end

		-- Store original modifiable state
		local original_modifiable = vim.api.nvim_get_option_value("modifiable", { buf = buf })

		self.winid = win
		self.bufnr = buf
		self.original_modifiable = original_modifiable

		local initialize_window_keymaps = require("ascii-ui.window.keymaps")
		initialize_window_keymaps(self)
	end

	-- Override close to restore original state
	window.close = function(self)
		-- Restore original modifiable state
		if self.original_modifiable ~= nil then
			vim.api.nvim_set_option_value("modifiable", self.original_modifiable, { buf = self.bufnr })
		end

		-- Don't close user-provided windows, just clear the buffer
		vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {})

		self.winid = nil
		self.bufnr = nil
	end

	return window
end

return M
