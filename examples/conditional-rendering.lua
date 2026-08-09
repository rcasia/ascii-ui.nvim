local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useState = ui.hooks.useState

local function App()
	local show, setShow = useState(true)
	return {
		show and Paragraph({ content = "Now you see me!" }) or nil,
		Button({
			label = "Toggle",
			on_press = function()
				setShow(not show)
			end,
		}),
	}
end

ui.mount(ui.createComponent("App", App))
