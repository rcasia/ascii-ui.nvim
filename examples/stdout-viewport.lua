local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local StdoutViewport = ui.viewports.StdoutViewport

--- @type ascii-ui.FunctionalComponent
local App = ui.createComponent("App", function()
	return {
		Paragraph({ content = "Hello from StdoutViewport!" }),
		Button({ label = "press me", on_press = function() end }),
	}
end)

ui.mount(App, StdoutViewport.new())
