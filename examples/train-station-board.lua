local Segment = require("ascii-ui.buffer.segment")
local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState
local useInterval = ui.hooks.useInterval

local function ScrollingText(props)
	local text = props.text
	local width = props.width or 50
	local speed = props.speed or 100
	local total_cycle = width + #text
	local offset, setOffset = useState(#text)

	useInterval(function()
		setOffset(function(o)
			return (o + 1) % total_cycle
		end)
	end, speed)

	local content
	if offset < #text then
		local visible = text:sub(1, offset)
		content = (" "):rep(width - offset) .. visible
	else
		local start = offset - #text + 1
		local visible = text:sub(start, math.min(start + width - 1, #text))
		content = visible .. (" "):rep(width - #visible)
	end

	return { Segment:new({ content = content }):wrap() }
end

local ScrollingTextComponent = ui.createComponent("ScrollingText", ScrollingText, {
	text = "string",
	width = "number",
	speed = "number",
})

local App = ui.createComponent("App", function()
	return {
		Paragraph({ content = "=== Station Board ===" }),
		Paragraph({ content = "" }),
		ScrollingTextComponent({
			text = "Next station: Central - Departure in 5 minutes",
			width = 50,
			speed = 150,
		}),
		Paragraph({ content = "" }),
		ScrollingTextComponent({
			text = "Service is operating normally",
			width = 50,
			speed = 120,
		}),
	}
end)

ui.mount(App)
