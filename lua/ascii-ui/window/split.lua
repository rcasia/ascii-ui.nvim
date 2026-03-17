local Window = require("ascii-ui.window")

---@class ascii-ui.SplitWindowOpts : ascii-ui.WindowOpts
---@field position? "left" | "right" | "top" | "bottom" Position of the split (defaults to "right")
---@field size? integer Size of the split (width for left/right, height for top/bottom)

local M = {}

--- Creates a split window (lateral or horizontal).
---@tag ascii-ui.window.split.create()
---
---@param opts? ascii-ui.SplitWindowOpts
---@return ascii-ui.Window
function M.create(opts)
	opts = opts or {}

	local window = Window.new(opts)

	-- Mark this as a split window (so update() knows not to use nvim_win_set_config)
	window.is_split = true
	window.split_position = opts.position or "right"
	window.fixed_size = opts.size -- Store the fixed size if provided

	-- Override the open method to create a split window
	window.open = function(self)
		-- Create a new unlisted, scratch buffer
		local buf = vim.api.nvim_create_buf(false, true)

		local position = opts.position or "right"
		local size = opts.size

		-- Determine split command and size
		local split_cmd
		if position == "left" then
			split_cmd = "topleft vsplit"
			size = size or self.opts.width or 40
		elseif position == "right" then
			split_cmd = "botright vsplit"
			size = size or self.opts.width or 40
		elseif position == "top" then
			split_cmd = "topleft split"
			size = size or self.opts.height or 20
		elseif position == "bottom" then
			split_cmd = "botright split"
			size = size or self.opts.height or 20
		else
			error("Invalid position: " .. position)
		end

		-- Create split
		vim.cmd(split_cmd)
		local win = vim.api.nvim_get_current_win()

		-- Set buffer and size
		vim.api.nvim_win_set_buf(win, buf)

		if position == "left" or position == "right" then
			vim.api.nvim_win_set_width(win, size)
		else
			vim.api.nvim_win_set_height(win, size)
		end

		vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

		self.winid = win
		self.bufnr = buf

		local initialize_window_keymaps = require("ascii-ui.window.keymaps")
		initialize_window_keymaps(self)
	end

	return window
end

return M
