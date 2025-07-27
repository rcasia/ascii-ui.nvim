local Cursor = require("ascii-ui.cursor")
local config = require("ascii-ui.config")
local i = require("ascii-ui.interaction_type")
local logger = require("ascii-ui.logger")
local user_interations = require("ascii-ui.user_interactions")

local on_select = function(window)
	vim.keymap.set("n", config.keymaps.select, function()
		logger.debug("--------- USER-INTERACTIONS SELECT ---------")
		logger.debug("Select key pressed, interacting with user interactions")
		local bufnr = vim.api.nvim_get_current_buf()
		local position = Cursor.current_position()

		user_interations:instance():interact({ buffer_id = bufnr, position = position, interaction_type = i.SELECT })
	end, { buffer = window.bufnr, noremap = true, silent = true })
end

return on_select
