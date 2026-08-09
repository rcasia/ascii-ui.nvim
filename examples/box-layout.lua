local ui = require("ascii-ui")
local Box = ui.components.Box
local Paragraph = ui.components.Paragraph

local function App()
	return {
		Box({ width = 30, height = 5, content = "Hello, World!" }),
		Paragraph({ content = "" }),
		Box({ width = 20, height = 3, content = "Small box" }),
	}
end

ui.mount(ui.createComponent("App", App))
