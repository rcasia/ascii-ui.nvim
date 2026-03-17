local Window = require("ascii-ui.window")

---@class ascii-ui.FloatingWindowOpts : ascii-ui.WindowOpts
---@field row? integer Row position (defaults to centered)
---@field col? integer Column position (defaults to centered)
---@field border? string Border style (defaults to "rounded")
---@field relative? string Relative positioning (defaults to "editor")

local M = {}

--- Creates a floating window (centered by default, or at specified position).
---@tag ascii-ui.window.floating.create()
---
---@param opts? ascii-ui.FloatingWindowOpts
---@return ascii-ui.Window
function M.create(opts)
	opts = opts or {}

	local window = Window.new(opts)

	-- Override the open method to create a floating window
	window.open = function(self)
		-- Create a new unlisted, scratch buffer
		local buf = vim.api.nvim_create_buf(false, true)

		-- Get window size for centering
		local editor_width = vim.api.nvim_win_get_width(0)
		local editor_height = vim.api.nvim_win_get_height(0)

		local win_width = self.opts.width or Window.default_opts.width
		local win_height = self.opts.height or Window.default_opts.height

		-- Calculate position (centered by default)
		local row = opts.row or math.floor((editor_height - win_height) / 2)
		local col = opts.col or math.floor((editor_width - win_width) / 2)

		-- Open floating window
		local win = vim.api.nvim_open_win(buf, true, {
			relative = opts.relative or "editor",
			width = win_width,
			height = win_height,
			row = row,
			col = col,
			style = "minimal",
			border = opts.border or "rounded",
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
