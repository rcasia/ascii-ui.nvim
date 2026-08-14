--- Input handler for ascii-ui.
---
--- Encapsulates all insert-mode input handling for the Input component.
--- Dependencies are injected via constructor for testability.
---
--- @module ascii-ui.input-handler

local Cursor = require("ascii-ui.cursor")
local logger = require("ascii-ui.logger")

--- @class ascii-ui.InputHandlerDeps
--- @field window ascii-ui.Window The viewport
--- @field renderedBufferGetter fun(): ascii-ui.Buffer Returns current rendered buffer
--- @field editingLineGetter fun(): integer|nil Returns line being edited
--- @field editingLineSetter fun(line: integer|nil) Sets the editing line

--- @class ascii-ui.InputHandler
--- @field private _deps ascii-ui.InputHandlerDeps
--- @field private _autocmd_ids integer[] Autocmd IDs for cleanup
--- @field private _keymaps table[] Keymap info for cleanup
local InputHandler = {}
InputHandler.__index = InputHandler

--- Creates a new InputHandler with injected dependencies.
--- @param deps ascii-ui.InputHandlerDeps
--- @return ascii-ui.InputHandler
function InputHandler.new(deps)
	local state = {
		_deps = deps,
		_autocmd_ids = {},
		_keymaps = {},
	}
	return setmetatable(state, InputHandler)
end

--- Sets up all autocmds and keymaps for input handling.
function InputHandler:setup()
	local window = self._deps.window
	local bufnr = window:get_bufnr()

	-- Enter insert mode on inputable segments when pressing 'i'
	vim.keymap.set("n", "i", function()
		if not window:is_focused() then
			return
		end
		local current_buffer = self._deps.renderedBufferGetter()
		local segment = current_buffer:find_segment_by_position(Cursor.current_position())
		if segment and segment:is_inputable() then
			self._deps.editingLineSetter(Cursor.current_position().line)
			vim.cmd("startinsert")
		end
	end, { buffer = bufnr, noremap = true, silent = true })
	table.insert(self._keymaps, { mode = "n", lhs = "i", bufnr = bufnr })

	-- InsertLeave autocmd: sync state when exiting insert mode
	local insert_leave_id = vim.api.nvim_create_autocmd("InsertLeave", {
		callback = function()
			local editing_line = self._deps.editingLineGetter()
			if not editing_line then
				return
			end
			local line = vim.api.nvim_buf_get_lines(bufnr, editing_line - 1, editing_line, false)[1] or ""
			local current_buffer = self._deps.renderedBufferGetter()
			local segment = current_buffer:find_segment_by_position({ line = editing_line, col = 0 })
			if segment then
				local callbacks = segment:get_input_callbacks()
				if callbacks then
					callbacks.state_setter(line)
					if callbacks.on_blur then
						callbacks.on_blur(line)
					end
				end
			end
			self._deps.editingLineSetter(nil)
		end,
	})
	table.insert(self._autocmd_ids, insert_leave_id)

	-- TextChangedI autocmd: fire on_change callback during insert mode
	local text_changed_id = vim.api.nvim_create_autocmd("TextChangedI", {
		callback = function()
			local editing_line = self._deps.editingLineGetter()
			if not editing_line then
				return
			end
			local line = vim.api.nvim_buf_get_lines(bufnr, editing_line - 1, editing_line, false)[1] or ""
			local current_buffer = self._deps.renderedBufferGetter()
			local segment = current_buffer:find_segment_by_position({ line = editing_line, col = 0 })
			if segment then
				local callbacks = segment:get_input_callbacks()
				if callbacks and callbacks.on_change then
					callbacks.on_change(line)
				end
			end
		end,
	})
	table.insert(self._autocmd_ids, text_changed_id)

	-- Insert-mode <CR> keymap: fire on_submit and exit insert mode
	vim.keymap.set("i", "<CR>", function()
		local editing_line = self._deps.editingLineGetter()
		if not editing_line then
			return "<CR>"
		end
		local line = vim.api.nvim_buf_get_lines(bufnr, editing_line - 1, editing_line, false)[1] or ""
		local current_buffer = self._deps.renderedBufferGetter()
		local segment = current_buffer:find_segment_by_position({ line = editing_line, col = 0 })
		if segment then
			local callbacks = segment:get_input_callbacks()
			if callbacks and callbacks.on_submit then
				callbacks.on_submit(line)
			end
		end
		vim.cmd("stopinsert") -- triggers InsertLeave → state sync
		return "" -- consume <CR>, don't insert newline
	end, { buffer = bufnr, noremap = true, expr = true })
	table.insert(self._keymaps, { mode = "i", lhs = "<CR>", bufnr = bufnr })

	logger.debug("InputHandler setup complete for buffer %d", bufnr)
end

--- Tears down all autocmds and keymaps.
function InputHandler:teardown()
	-- Clean up autocmds
	for _, id in ipairs(self._autocmd_ids) do
		pcall(vim.api.nvim_del_autocmd, id)
	end
	self._autocmd_ids = {}

	-- Clean up keymaps
	for _, km in ipairs(self._keymaps) do
		pcall(vim.keymap.del, km.mode, km.lhs, { buffer = km.bufnr })
	end
	self._keymaps = {}

	-- Reset editing line
	self._deps.editingLineSetter(nil)

	logger.debug("InputHandler teardown complete")
end

--- Pre-render guard for STATE_CHANGE handler.
--- Saves the editing line content before render and returns a restoration function.
--- @return fun() restore Function to call after render to restore editing line
function InputHandler:pre_render_guard()
	local editing_line = self._deps.editingLineGetter()
	if not editing_line or vim.fn.mode() ~= "i" then
		return function() end -- no-op restore
	end

	local window = self._deps.window
	local bufnr = window:get_bufnr()
	local win_id = window:get_id()

	-- Save current state
	local saved_content = vim.api.nvim_buf_get_lines(bufnr, editing_line - 1, editing_line, false)[1]
	local cursor_col = vim.api.nvim_win_get_cursor(win_id)[2]

	logger.debug("Pre-render guard: saving line %d content: %s", editing_line, saved_content)

	-- Return restoration function
	return function()
		if not saved_content then
			return
		end
		-- Restore line content
		pcall(vim.api.nvim_buf_set_lines, bufnr, editing_line - 1, editing_line, false, { saved_content })
		-- Restore cursor position
		pcall(vim.api.nvim_win_set_cursor, win_id, { editing_line, cursor_col })
		logger.debug("Pre-render guard: restored line %d", editing_line)
	end
end

return InputHandler
