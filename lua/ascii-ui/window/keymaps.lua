local Command = require("ascii-ui.commands")
local Cursor = require("ascii-ui.cursor")
local config = require("ascii-ui.config")
local logger = require("ascii-ui.logger")
local throttle = require("ascii-ui.utils.strict_throttle")

-- TODO: make configurable as fps
local THROTTLE_DELAY = 50 -- milliseconds

--- Sets up window keymaps that dispatch commands through the bus.
---
--- @param window ascii-ui.Window
--- @param bus ascii-ui.EventBus
return function(window, bus)
	-- Quit keymap: dispatch CLOSE_WINDOW
	vim.keymap.set("n", config.keymaps.quit, function()
		logger.debug("Quit key pressed, dispatching CLOSE_WINDOW")
		bus:dispatch(Command.CloseWindow({ window_id = window:get_id() }))
	end, { buffer = window.bufnr, noremap = true, silent = true })

	-- Select keymap: dispatch SELECT
	vim.keymap.set("n", config.keymaps.select, function()
		logger.debug("Select key pressed, dispatching SELECT")
		local position = Cursor.current_position()
		bus:dispatch(Command.Select({
			window_id = window:get_id(),
			position = position,
		}))
	end, { buffer = window.bufnr, noremap = true, silent = true })

	-- Mouse drag: dispatch MOVE_WINDOW
	--- @type ascii-ui.Position | nil
	local mouse_cursor_offset
	vim.keymap.set("n", "<LeftMouse>", function()
		local mouse_pos = vim.fn.getmousepos()
		mouse_cursor_offset = {
			line = mouse_pos.screenrow - window:position().line,
			col = mouse_pos.screencol - window:position().col,
		}
		logger.debug("Left mouse key pressed. mouse cursor position: %s", vim.inspect(mouse_pos))
		logger.debug("window position: %s", vim.inspect(window:position()))
	end, { buffer = window.bufnr, noremap = true, silent = true })

	vim.keymap.set(
		"n",
		"<LeftDrag>",
		throttle(function()
			if not mouse_cursor_offset then
				return
			end
			local mouse_pos = vim.fn.getmousepos()
			local window_pos = window:position()

			local movement_vector = {
				line = mouse_pos.screenrow - window_pos.line,
				col = mouse_pos.screencol - window_pos.col,
			}

			-- consider the offset
			local new_position = {
				line = window_pos.line - mouse_cursor_offset.line + movement_vector.line,
				col = window_pos.col - mouse_cursor_offset.col + movement_vector.col,
			}

			bus:dispatch(Command.MoveWindow({
				window_id = window:get_id(),
				position = new_position,
			}))
		end, THROTTLE_DELAY),
		{ buffer = window.bufnr, noremap = true, silent = true }
	)
end
