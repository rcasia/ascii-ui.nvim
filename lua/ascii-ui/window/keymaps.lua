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

return function(window)
	on_quit(window)
	on_select(window)
end
