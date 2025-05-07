local ui = require("ascii-ui")
local Paragraph = ui.components.paragraph.fun
local Layout = ui.layout.fun
local Button = ui.components.button.fun
local useState = require("ascii-ui.hooks.use_state")

--- @type ascii-ui.FunctionalComponent
local function App()
	local content, setContent = useState("initial content")

	return function()
		return Layout(
			--
			Paragraph({ content = content }),
			Button({
				label = "change",
				on_press = function()
					setContent("changed content")
				end,
			})
		)()
	end
end

ui.mount(App())
