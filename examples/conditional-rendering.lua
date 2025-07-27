local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Column = ui.layout.Column
local Button = ui.components.Button
local useState = ui.hooks.useState
local If = ui.components.If

--- @type ascii-ui.FunctionalComponent
local App = ui.createComponent("App", function()
	local shouldShow, setShouldShow = useState(true)
	return Column(
		If({
			condition = function()
				return shouldShow
			end,
			child = Paragraph({ content = "this is my content" }),
			fallback = Paragraph({ content = "hidden" }),
		}),

		Button({
			label = "change",
			on_press = function()
				setShouldShow(not shouldShow)
			end,
		})
	)
end)

ui.mount(App)
