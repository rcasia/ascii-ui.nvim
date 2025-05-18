local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Layout = ui.layout
local Button = ui.components.Button
local useState = ui.hooks.useState
local If = require("ascii-ui.components.if")

--- @type ascii-ui.FunctionalComponent
local function App()
	local shouldShow, setShouldShow = useState(true)

	return Layout(
		If({
			condition = function()
				return shouldShow()
			end,
			child = Paragraph({ content = "this is my content" }),
			fallback = Paragraph({ content = "hidden" }),
		}),

		Button({
			label = "change",
			on_press = function()
				setShouldShow(not shouldShow())
			end,
		})
	)
end

ui.mount(App())
