-- Simple example showing how to use a split window
-- Run this with: :luafile examples/sidebar-example.lua

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph

--- @type ascii-ui.FunctionalComponent
local Sidebar = ui.createComponent("Sidebar", function()
	return {
		Paragraph({ content = "Project Explorer" }),
		Paragraph({ content = "=================" }),
		Paragraph({ content = "" }),
		Paragraph({ content = "src/" }),
		Paragraph({ content = "  components/" }),
		Paragraph({ content = "  utils/" }),
		Paragraph({ content = "tests/" }),
		Paragraph({ content = "README.md" }),
	}
end)

-- Create a left sidebar split window
local sidebar_window = ui.window.split.create({
	position = "left",
	size = 30,
})

ui.mount(Sidebar, sidebar_window)
