local ui = require("ascii-ui")
local Checkbox = ui.components.Checkbox
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useState = ui.hooks.useState

local function App()
	local checked, setChecked = useState(false)
	return {
		Checkbox({ active = checked, label = "I agree to the terms" }),
		Button({
			label = checked and "Accepted!" or "Toggle",
			on_press = function()
				setChecked(not checked)
			end,
		}),
		Paragraph({ content = checked and "Thank you!" or "" }),
	}
end

ui.mount(ui.createComponent("App", App))
