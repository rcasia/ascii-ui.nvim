local logger = require("ascii-ui.logger")
local nvim_win_get_cursor = vim.api.nvim_win_get_cursor

--- @class ascii-ui.Cursor
--- @field buffers table<number, boolean>
--- @field last_position ascii-ui.CursorPosition | nil
--- @field _current_position ascii-ui.CursorPosition | nil
local Cursor = {
	buffers = {},
	--- @enum (key) ascii-ui.CursorDirection
	DIRECTION = {
		SOUTH = "SOUTH",
		NORTH = "NORTH",
	},
	_current_position = nil,
	last_position = nil,
}

--- @class ascii-ui.CursorPosition
--- @field line number
--- @field col number

--- @return ascii-ui.CursorPosition
function Cursor.current_position()
	local pos = nvim_win_get_cursor(0)
	return { line = pos[1], col = pos[2] }
end

function Cursor.trigger_move_event()
	Cursor.last_position = Cursor._current_position or Cursor.current_position()
	Cursor._current_position = Cursor.current_position()

	logger.debug("CursorMoved to %s", vim.inspect(Cursor._current_position))
end

function Cursor.attach_buffer(bufnr)
	Cursor.buffers[bufnr] = true
end

--- @return ascii-ui.CursorDirection
function Cursor.last_movement_direction()
	print(Cursor.last_position.line, Cursor._current_position.line)
	if Cursor.last_position.line > Cursor._current_position.line then
		return Cursor.DIRECTION.NORTH
	end
	return Cursor.DIRECTION.SOUTH
end

-- binds to window close event
vim.api.nvim_create_autocmd("CursorMoved", {
	callback = function(args)
		if not Cursor.buffers[args.buf] then
			return
		end
		logger.debug("cursormoved event on bufnr: %s", args.buf)
		Cursor:trigger_move_event()
	end,
})

return Cursor
