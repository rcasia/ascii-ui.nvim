local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState
local useInterval = ui.hooks.useInterval

local function Clock()
	local time, setTime = useState(os.date("%H:%M:%S"))

	useInterval(function()
		setTime(os.date("%H:%M:%S"))
	end, 1000)

	return { Paragraph({ content = time }) }
end

ui.mount(ui.createComponent("App", Clock))
