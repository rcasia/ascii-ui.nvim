local config = require("ascii-ui.config")
local i = require("ascii-ui.interaction_type")
local logger = require("ascii-ui.logger")
local user_interations = require("ascii-ui.user_interactions")

local on_quit = function(window)
	vim.keymap.set("n", config.keymaps.quit, function()
		window:close()
	end, { buffer = window.bufnr, noremap = true, silent = true })
end

local on_select = function(window)
	vim.keymap.set("n", config.keymaps.select, function()
		logger.debug("Select key pressed, interacting with user interactions")
		local bufnr = vim.api.nvim_get_current_buf()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local position = { line = cursor[1], col = cursor[2] }

		user_interations:instance():interact({ buffer_id = bufnr, position = position, interaction_type = i.SELECT })
	end, { buffer = window.bufnr, noremap = true, silent = true })
end

local on_left_drag = function(window)
	--- @type ascii-ui.Position
	local mouse_win_relative_position
	vim.keymap.set("n", "<LeftMouse>", function()
		local mouse_pos = vim.fn.getmousepos()
		mouse_win_relative_position = {
			line = mouse_pos.screenrow - window:position().line,
			col = mouse_pos.screencol - window:position().col,
		}
		logger.debug("Left mouse key pressed. mouse cursor position: %s", vim.inspect(mouse_pos))
		logger.debug("window position: %s", vim.inspect(window:position()))
	end, { buffer = window.bufnr, noremap = true, silent = true })

	vim.keymap.set("n", "<LeftDrag>", function()
		local mouse_pos = vim.fn.getmousepos()
		local window_pos = window:position()

		local movement_vector = {
			line = mouse_pos.screenrow - window_pos.line,
			col = mouse_pos.screencol - window_pos.col,
		}

		-- consider the offset
		local new_position = {
			line = window_pos.line - mouse_win_relative_position.line + movement_vector.line,
			col = window_pos.col - mouse_win_relative_position.col + movement_vector.col,
		}

		window:move_to(new_position)
	end, { buffer = window.bufnr, noremap = true, silent = true })
end

return function(window)
	on_quit(window)
	on_select(window)
	on_left_drag(window)
end
