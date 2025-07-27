--- @class ascii-ui.Config
local config = {
	---@type ascii-ui.Logger.LogLevel
	log_level = "INFO",
	characters = {
		top_left = "╭",
		top_right = "╮",
		bottom_left = "╰",
		bottom_right = "╯",
		horizontal = "─",
		vertical = "│",
		left_tree = "├",
		thumb = "●",
		whitespace = " ",
		right_triangule = "▸",
		down_triangule = "▾",
	},
	keymaps = {
		quit = "q",
		select = "<CR>",
	},
}

return config
