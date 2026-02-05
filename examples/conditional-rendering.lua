local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useState = ui.hooks.useState

--- @type ascii-ui.FunctionalComponent
local App = ui.createComponent("App", function()
	local shouldShow, setShouldShow = useState(true)

	local component
	if shouldShow then
		component = Paragraph({ content = "this is my content" })
	else
		component = Paragraph({ content = "hidden" })
	end

	return {
		component,

		Button({
			label = "change",
			on_press = function()
				setShouldShow(not shouldShow)
			end,
		}),
	}
end)

ui.mount(App)
