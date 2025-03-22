---@alias ascii-ui.WindowOpts { width?: integer, height?: integer }

---@class ascii-ui.Window
---@field winid integer
---@field bufnr integer
---@field opts ascii-ui.WindowOpts
local Window = {
	---@type ascii-ui.WindowOpts
	default_opts = { width = 40, height = 20 },
}

---@param opts? ascii-ui.WindowOpts
---@return ascii-ui.Window
function Window:new(opts)
	opts = opts or {}
	opts = vim.tbl_extend("force", self.default_opts, opts)

	-- set default color
	local hl = vim.api.nvim_get_hl(0, { name = "Normal" })
	vim.api.nvim_set_hl(0, "AsciiUiWindow", { fg = hl.fg, bg = hl.bg })

	local state = {
		winid = nil,
		bufnr = nil,
		opts = opts,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

function Window:open()
	-- Create a new unlisted, scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Open a floating window with the new buffer
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = self.opts.width,
		height = self.opts.height,
		col = 10,
		row = 10,
		style = "minimal",
		border = "rounded",
	})

	vim.api.nvim_win_get_buf(win)

	-- Assume `buf` is the buffer ID associated with your window.
	vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })

	self.winid = win
	self.bufnr = buf
end

---@return boolean
function Window:is_open()
	return self.winid ~= nil and self.bufnr ~= nil
end

function Window:close()
	vim.api.nvim_win_close(self.winid, true)
	self.winid = nil
	self.bufnr = nil
end

---@param buffer ascii-ui.Buffer
function Window:update(buffer)
	local buffer_content = buffer:to_lines()
	vim.schedule(function()
		-- buffer content
		vim.api.nvim_set_option_value("modifiable", true, { buf = self.bufnr })
		vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, buffer_content)
		vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })

		-- coloring
		local function apply_highlight(bufnr)
			-- NOTE: Good for updating all the window
			-- but unoptimal for just parts of the window or buffer
			-- for that use: nvim_buf_set_extmark
			vim.api.nvim_set_option_value("winhl", "Normal:AsciiUiWindow", { win = self.winid })
		end

		apply_highlight(self.bufnr)
	end)
end

return Window
