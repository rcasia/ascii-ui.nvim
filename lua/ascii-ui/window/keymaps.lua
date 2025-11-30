local on_left_drag = require("ascii-ui.window.on_left_drag")
local on_quit = require("ascii-ui.window.on_quit")
local on_select = require("ascii-ui.window.on_select")

--- @param window ascii-ui.Window
return function(window)
	on_quit(window)
	on_select(window)
	on_left_drag(window)
end
