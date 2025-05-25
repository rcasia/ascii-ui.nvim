local highlights = require("ascii-ui.highlights")
local logger = require("ascii-ui.logger")
---@alias ascii-ui.WindowOpts { width?: integer, height?: integer }

---@class ascii-ui.Window
---@field winid integer
---@field bufnr integer
---@field ns_id integer
---@field opts ascii-ui.WindowOpts
local Window = {
	---@type ascii-ui.WindowOpts
	default_opts = { width = 40, height = 20 },
}
Window.__index = Window

---@param opts? ascii-ui.WindowOpts
---@return ascii-ui.Window
function Window.new(opts)
	opts = opts or {}
	opts = vim.tbl_extend("force", Window.default_opts, opts)

	-- set default color
	local hl = vim.api.nvim_get_hl(0, { name = "Normal" })
	vim.api.nvim_set_hl(0, highlights.DEFAULT, { fg = hl.fg, bg = hl.bg })

	-- set custom colors
	local ns_id = vim.api.nvim_create_namespace("ascii-ui")
	vim.api.nvim_set_hl(0, highlights.SELECTION, { fg = "#f6b93b" })
	vim.api.nvim_set_hl(0, highlights.BUTTON, { fg = hl.bg, bg = "#f6b93b" })

	local state = {
		winid = nil,
		bufnr = nil,
		ns_id = ns_id,
		opts = opts,
		edits_enabled = false,
	}

	setmetatable(state, Window)

	return state
end

function Window:open()
	-- Create a new unlisted, scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- current window size
	local width = vim.api.nvim_win_get_width(0)
	local height = vim.api.nvim_win_get_height(0)
	local center = { line = math.floor(height / 2), col = math.floor(width / 2) }

	-- Open a floating window with the new buffer
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = self.opts.width,
		height = self.opts.height,
		col = center.col - math.floor(self.opts.width / 2),
		row = center.line - math.floor(self.opts.height / 2),
		style = "minimal",
		border = "rounded",
	})

	vim.api.nvim_win_get_buf(win)

	-- Assume `buf` is the buffer ID associated with your window.
	vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })

	self.winid = win
	self.bufnr = buf

	--- @type ascii-ui.Position
	local mouse_win_relative_position
	vim.keymap.set("n", "<LeftMouse>", function()
		local mouse_pos = vim.fn.getmousepos()
		mouse_win_relative_position = {
			line = mouse_pos.screenrow - self:position().line,
			col = mouse_pos.screencol - self:position().col,
		}
		logger.debug("Left mouse key pressed. mouse cursor position: %s", vim.inspect(mouse_pos))
		logger.debug("window position: %s", vim.inspect(self:position()))
	end, { buffer = self.bufnr, noremap = true, silent = true })

	vim.keymap.set("n", "<LeftDrag>", function()
		local mouse_pos = vim.fn.getmousepos()
		local window_pos = self:position()

		local movement_vector = {
			line = mouse_pos.screenrow - window_pos.line,
			col = mouse_pos.screencol - window_pos.col,
		}

		-- consider the offset
		local new_position = {
			line = window_pos.line - mouse_win_relative_position.line + movement_vector.line,
			col = window_pos.col - mouse_win_relative_position.col + movement_vector.col,
		}

		self:move_to(new_position)
	end, { buffer = self.bufnr, noremap = true, silent = true })
end

--- Get the position of the window
--- @return ascii-ui.Position
function Window:position()
	local pos = vim.api.nvim_win_get_position(self.winid)
	return {
		line = pos[1],
		col = pos[2],
	}
end

--- Move the window to a specific position
--- @param position ascii-ui.Position
function Window:move_to(position)
	if self:is_close() then
		error("Cannot move window: window or buffer is not open")
	end
	vim.api.nvim_win_set_config(self.winid, {
		relative = "editor",
		row = position.line,
		col = position.col,
	})
end

function Window:enable_edits()
	if self:is_close() then
		error("Cannot enable edits: window or buffer is not open")
	end
	logger.debug("Edits are enabled for window/buffer (%d/%d)", self.winid, self.bufnr)
	self.edits_enabled = true
	vim.api.nvim_set_option_value("modifiable", true, { buf = self.bufnr })
end

function Window:disable_edits()
	if self:is_close() then
		error("Cannot disable edits: window or buffer is not open")
	end
	logger.debug("Edits are disabled for window/buffer (%d/%d)", self.winid, self.bufnr)
	self.edits_enabled = false
	vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })
end

---@return boolean
function Window:is_open()
	return self.winid ~= nil or self.bufnr ~= nil
end

function Window:is_close()
	return not self:is_open()
end

function Window:close()
	vim.api.nvim_win_close(self.winid, true)
	self.winid = nil
	self.bufnr = nil

	-- restore modifiable for the bufnr
	vim.api.nvim_set_option_value("modifiable", true, { buf = self.bufnr })
end

---@param buffer ascii-ui.Buffer
function Window:update(buffer)
	logger.debug("Updating window with id %s and bufnr %s", self.winid, self.bufnr)

	if not self:is_open() then
		error("Window is not open")
	end
	vim.schedule(function()
		-- buffer content
		if not self.edits_enabled then
			vim.api.nvim_set_option_value("modifiable", true, { buf = self.bufnr })
		end
		vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, buffer:to_lines())

		if not self.edits_enabled then
			vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })
		end

		-- resize window
		vim.api.nvim_win_set_config(self.winid, {
			width = buffer:width(),
			height = buffer:height(),
		})
		-- adjust scroll
		vim.api.nvim_win_call(0, function()
			local win = vim.api.nvim_get_current_win()
			local curpos = vim.api.nvim_win_get_cursor(win)

			-- Move cursor to top, scroll, restore
			vim.api.nvim_win_set_cursor(win, { 1, 0 })
			vim.cmd("normal! zt")
			vim.api.nvim_win_set_cursor(win, curpos)
		end)

		-- coloring
		local function apply_highlight()
			vim.api.nvim_buf_clear_namespace(self.bufnr, self.ns_id, 0, -1)

			-- NOTE: Good for updating all the window
			-- but unoptimal for just parts of the window or buffer
			-- for that use: nvim_buf_set_extmark
			vim.api.nvim_set_option_value("winhl", ("Normal:%s"):format(highlights.DEFAULT), { win = self.winid })

			for element_result in buffer:iter_colored_elements() do
				local pos = element_result.position
				local element = element_result.element
				local end_col = pos.col + element:len()

				vim.api.nvim_buf_set_extmark(self.bufnr, self.ns_id, pos.line - 1, pos.col - 1, {
					end_col = end_col - 1,
					strict = false,
					hl_group = element.highlight,
				})
			end
		end

		apply_highlight()
	end)
end

return Window
