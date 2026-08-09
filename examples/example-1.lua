local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useState = ui.hooks.useState

local function Counter()
	local count, setCount = useState(0)
	return {
		Paragraph({ content = "Count: " .. count }),
		Button({
			label = "+1",
			on_press = function()
				setCount(count + 1)
			end,
		}),
	}
end

ui.mount(ui.createComponent("App", Counter))
