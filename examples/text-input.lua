local ui = require("ascii-ui")
local Input = ui.components.Input
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState

local function App()
	local text = useState("Type something...")
	return {
		Paragraph({ content = "Edit the text below:" }),
		Input({ value = text }),
	}
end

ui.mount(ui.createComponent("App", App))
