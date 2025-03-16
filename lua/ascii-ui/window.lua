---@alias ascii-ui.WindowOpts { width?: integer, height?: integer }

---@class ascii-ui.Window
local Window = {
	---@type ascii-ui.WindowOpts
	default_opts = { width = 40, height = 20 },
}

---@param opts? ascii-ui.WindowOpts
---@return ascii-ui.Window
function Window:new(opts)
	opts = opts or {}
	opts = vim.tbl_extend("force", self.default_opts, opts)

	local state = {
		_is_color_set = false,
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

---@param buffer_content string[]
function Window:update(buffer_content)
	vim.schedule(function()
		vim.api.nvim_set_option_value("modifiable", true, { buf = self.bufnr })
		vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, buffer_content)
		vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })
		if self._is_color_set == false then
			self._is_color_set = true

			-- Create a namespace for your highlights.
			local ns_id = vim.api.nvim_create_namespace("my_namespace")

			-- Define a highlight group.
			vim.api.nvim_set_hl(0, "MyHighlight", { fg = "#d1ccc0", bg = "#2c2c54", bold = true })

			local function apply_highlight(bufnr)
				-- Clear previous extmarks in the namespace (if needed)
				vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

				-- Set an extmark on the first line from column 0 to 10.
				vim.api.nvim_buf_set_extmark(bufnr, ns_id, 0, 0, {
					end_line = self.opts.height - 1, -- highlight ends on the same line
					end_col = self.opts.width - 1, -- highlight from col 0 to 10
					hl_group = "MyHighlight",
				})
			end

			-- Apply the highlight initially.
			apply_highlight(self.bufnr)

			-- Set up an autocommand to reapply the highlight when the buffer changes.
			vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
				buffer = self.bufnr,
				callback = function()
					-- Ensure we're in the main context
					vim.schedule(function()
						apply_highlight(self.bufnr)
					end)
				end,
			})
		end
	end)
end

return Window
