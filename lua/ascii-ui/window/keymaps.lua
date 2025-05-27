local config = require("ascii-ui.config")

local on_quit = function(window)
	vim.keymap.set("n", config.keymaps.quit, function()
		window:close()
	end, { buffer = window.bufnr, noremap = true, silent = true })
end

return function(window)
	on_quit(window)
end
