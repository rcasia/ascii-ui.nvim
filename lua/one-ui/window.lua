---@alias one-ui.WindowOpts { width: integer, height: integer }

local Window = {
	---@type one-ui.WindowOpts
	default_opts = { width = 40, height = 20 },
}

---@param opts one-ui.WindowOpts
function Window:new(opts)
	opts = opts or {}
	opts = vim.tbl_extend("force", self.default_opts, opts)

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
	})

	vim.api.nvim_win_get_buf(win)

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

return Window
