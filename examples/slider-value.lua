local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Slider = ui.components.Slider
local useState = ui.hooks.useState

local function App()
	local value, setValue = useState(50)
	return {
		Paragraph({ content = "Drag the knob (use h/l keys):" }),
		Slider({
			title = "Volume",
			value = value,
			on_change = function(v)
				setValue(v)
			end,
		}),
		Paragraph({ content = "Value: " .. value .. "%" }),
	}
end

ui.mount(ui.createComponent("App", App))
