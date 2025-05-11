local logger = require("ascii-ui.logger")
local highlights = require("ascii-ui.highlights")
local config = require("ascii-ui.config")

---@alias ascii-ui.WindowOpts { width?: integer, height?: integer, relative?: string, editable?: boolean, min_width?: integer, min_height?: integer, col?: integer, line?: integer }

---@class ascii-ui.Window
---@field winid integer
---@field bufnr integer
---@field ns_id integer
---@field opts ascii-ui.WindowOpts
local Window = {
	---@type ascii-ui.WindowOpts
	default_opts = { width = 40, height = 20, relative = "editor", min_width = 40, min_height = 20, editable = false },
}

---@param opts? ascii-ui.WindowOpts
---@return ascii-ui.Window
function Window:new(opts)
	opts = opts or {}
	opts = vim.tbl_extend("force", self.default_opts, opts)

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

	setmetatable(state, self)
	self.__index = self

	if not opts.editable then
		self:disable_edits()
	end

	return state
end

function Window:on_close(fn)
	self.on_close_fn = fn
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
		relative = self.opts.relative,
		width = self.opts.width,
		height = self.opts.height,
		col = self.opts.col or center.col - math.floor(self.opts.width / 2),
		row = self.opts.line or center.line - math.floor(self.opts.height / 2),
		style = "minimal",
		border = "rounded",
	})

	vim.api.nvim_win_get_buf(win)

	self.winid = win
	self.bufnr = buf

	vim.bo[buf].buftype = "nofile"

	vim.keymap.set("n", config.keymaps.quit, function()
		self:close()
	end, { buffer = self.bufnr, noremap = true, silent = true })
end

function Window:enable_edits()
	logger.debug("Window/Buffer edits are enabled")
	self.edits_enabled = true
	vim.api.nvim_set_option_value("modifiable", true, { buf = self.bufnr })
end

function Window:disable_edits()
	logger.debug("Window/Buffer edits are disabled")
	self.edits_enabled = false
	vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })
end

---@return boolean
function Window:is_open()
	return self.winid ~= nil and self.bufnr ~= nil
end

function Window:close()
	self:enable_edits()
	if self.on_close_fn then
		self:on_close_fn()
	end
	vim.api.nvim_win_close(self.winid, true)
	self.winid = nil
	self.bufnr = nil
end

--- @return string[]
function Window:read_buffer()
	return vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
end

---@param buffer ascii-ui.Buffer
function Window:update(buffer)
	logger.debug("Updating window with id %s and bufnr %s", self.winid, self.bufnr)

	if not self:is_open() then
		error("Window is not open")
	end
	vim.schedule(function()
		-- buffer content
		self:enable_edits()
		vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, buffer:to_lines())

		if not self.opts.editable then
			self:disable_edits()
		end

		-- resize window
		vim.api.nvim_win_set_config(self.winid, {
			width = math.max(buffer:width(), self.opts.min_width),
			height = math.max(buffer:height(), self.opts.min_height),
		})

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

function Window:on_autocommand(autocommand, fn)
	if not self:is_open() then
		error("Window is not open")
	end

	vim.api.nvim_create_autocmd(autocommand, {
		group = vim.api.nvim_create_augroup("ascii-ui", { clear = true }),
		buffer = self.bufnr,
		callback = function()
			fn(self)
		end,
	})
end

return Window
