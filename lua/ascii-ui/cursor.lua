local EventListener = require("ascii-ui.events")
local logger = require("ascii-ui.logger")

--- @class ascii-ui.Cursor
--- @field buffers table<number, boolean>
--- @field last_position ascii-ui.CursorPosition | nil
--- @field _current_position ascii-ui.CursorPosition | nil
local Cursor = {
	buffers = {},
	--- @enum (key) ascii-ui.CursorDirection
	DIRECTION = {
		NONE = "NONE",
		SOUTH = "SOUTH",
		NORTH = "NORTH",
		EAST = "EAST",
		WEST = "WEST",
	},
	EVENTS = {
		SOUTH = "CursorMovedSouth",
		NORTH = "CursorMovedNorth",
		EAST = "CursorMovedEast",
		WEST = "CursorMovedWest",
	},
	_current_position = nil,
	last_position = nil,
}

--- @class ascii-ui.CursorPosition
--- @field line integer
--- @field col integer

--- @return ascii-ui.CursorPosition
function Cursor.current_position()
	local row, byte_col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local visual_col = vim.str_utfindex(line, "utf-32", byte_col)
	return { line = row, col = visual_col }
end

function Cursor.trigger_move_event()
	Cursor.last_position = Cursor._current_position or Cursor.current_position()
	Cursor._current_position = Cursor.current_position()

	local last_movement_direction = Cursor.last_movement_direction()

	if last_movement_direction == "NONE" then
		return
	end

	EventListener:trigger(Cursor.EVENTS[Cursor.last_movement_direction()])

	logger.debug("CursorMoved to %s", vim.inspect(Cursor._current_position))
end

function Cursor.attach_buffer(bufnr)
	Cursor.buffers[bufnr] = true
end

--- @param position ascii-ui.Position
--- @param winid? integer
--- @param bufnr? integer
function Cursor.move_to(position, winid, bufnr)
	local line = vim.api.nvim_buf_get_lines(bufnr or 0, position.line - 1, position.line, false)[1] or ""
	local byte_col = vim.str_byteindex(line, "utf-8", position.col)

	logger.debug("TRYING TO SET CURSOR TO (%d, %d)", position.line, byte_col)
	vim.api.nvim_win_set_cursor(winid or 0, { position.line, byte_col })

	Cursor.last_position = Cursor._current_position or Cursor.current_position()
	Cursor._current_position = Cursor.current_position()
end

--- @return ascii-ui.CursorDirection
function Cursor.last_movement_direction()
	if Cursor.last_position.line == Cursor._current_position.line then
		if Cursor.last_position.col < Cursor._current_position.col then
			return Cursor.DIRECTION.EAST
		end

		if Cursor.last_position.col > Cursor._current_position.col then
			return Cursor.DIRECTION.WEST
		end

		return Cursor.DIRECTION.NONE
	end

	if Cursor.last_position.line > Cursor._current_position.line then
		return Cursor.DIRECTION.NORTH
	end

	return Cursor.DIRECTION.SOUTH
end

function Cursor.clear()
	Cursor.buffers = {}
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
