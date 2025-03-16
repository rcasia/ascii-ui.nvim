local Window = {}

function Window:new()
	local state = {
		winid = nil,
		bufnr = nil,
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
		width = 80,
		height = 20,
		col = 10,
		row = 10,
		style = "minimal",
	})

	-- Retrieve the buffer from the window (this returns the same buffer created above)
	local buf_from_win = vim.api.nvim_win_get_buf(win)

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
