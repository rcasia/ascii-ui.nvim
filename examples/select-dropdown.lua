local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Select = ui.components.Select
local useState = ui.hooks.useState

local function App()
	local selected, setSelected = useState("Lua")
	return {
		Paragraph({ content = "Pick your favorite language:" }),
		Select({
			options = { "Lua", "Python", "Rust", "Go" },
			on_select = function(name)
				setSelected(name)
			end,
		}),
		Paragraph({ content = "" }),
		Paragraph({ content = "You picked: " .. selected }),
	}
end

ui.mount(ui.createComponent("App", App))
