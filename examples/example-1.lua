local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useState = ui.hooks.useState

--- @type ascii-ui.FunctionalComponent
local App = ui.createComponent("App", function()
	local content, setContent = useState("initial content")
	return {
		--
		Paragraph({ content = content }),
		Button({
			label = "change",
			on_press = function()
				setContent("changed content")
			end,
		}),
	}
end)

ui.mount(App)
