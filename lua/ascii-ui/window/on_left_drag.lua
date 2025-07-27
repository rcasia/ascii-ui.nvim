local logger = require("ascii-ui.logger")
local throttle = require("ascii-ui.utils.strict_throttle")

-- TODO: make configurable as fps
local THROTTLE_DELAY = 50 -- milliseconds

local on_left_drag = function(window)
	--- @type ascii-ui.Position
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

			window:move_to(new_position)
		end, THROTTLE_DELAY),
		{ buffer = window.bufnr, noremap = true, silent = true }
	)
end

return on_left_drag
