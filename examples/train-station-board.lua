local Segment = require("ascii-ui.buffer.segment")
local ui = require("ascii-ui")
local Column = ui.layout.Column
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState
local useInterval = ui.hooks.useInterval

--- Component that displays text scrolling to the left (marquee effect)
--- @param props { text: string, width?: number, speed?: number }
local function ScrollingText(props)
	props = props or {}
	local text = props.text
	local width = props.width or 50 -- visible area width
	local speed = props.speed or 100 -- milliseconds between updates

	local text_len = text:len()
	-- Complete cycle: from when text is completely hidden on the right
	-- until it's completely hidden on the left
	local total_cycle = width + text_len
	local offset, setOffset = useState(text_len) -- Start with text completely visible

	-- Update position every 'speed' milliseconds
	-- Use a function in setOffset to get the current state value
	useInterval(function()
		setOffset(function(current_offset)
			return (current_offset + 1) % total_cycle
		end)
	end, speed)

	-- Calculate what to show based on offset position
	-- 'offset' goes from 0 to (width + text_len - 1)
	-- offset=0: text completely on the right (not visible, only spaces)
	-- offset increases: text enters from the right
	-- offset=text_len: text is completely visible
	-- offset continues increasing: text exits to the left
	-- offset=width+text_len-1: text completely on the left (not visible, only spaces)

	local content

	if offset == 0 then
		-- Only spaces when offset is 0 (text completely hidden on the right)
		content = (" "):rep(width)
	elseif offset > 0 and offset < text_len then
		-- Phase 1: Text enters from the right
		-- Show the first 'offset' characters of the text
		-- offset=1: show first character
		-- offset=2: show first 2 characters
		-- etc.
		local spaces_count = width - offset
		local visible_text = text:sub(1, offset)
		content = (" "):rep(spaces_count) .. visible_text
	elseif offset >= text_len and offset < total_cycle then
		-- Phase 2: Text moves to the left and exits
		-- offset >= text_len: text is completely visible or exiting
		local text_start = offset - text_len + 1
		local text_end = math.min(text_start + width - 1, text_len)

		if text_start <= text_len then
			-- Text is still partially visible
			local visible_text = text:sub(text_start, text_end)
			-- Complete with spaces on the right if necessary
			local visible_len = visible_text:len()
			content = visible_text .. (" "):rep(width - visible_len)
		else
			-- Text has completely exited, only spaces
			content = (" "):rep(width)
		end
	else
		-- Safety case: only spaces (this shouldn't happen with modulo)
		content = (" "):rep(width)
	end

	-- Ensure content has exactly 'width' characters
	local content_len = content:len()
	if content_len ~= width then
		if content_len < width then
			content = content .. (" "):rep(width - content_len)
		else
			content = content:sub(1, width)
		end
	end

	return { Segment:new({ content = content }):wrap() }
end

local ScrollingTextComponent = ui.createComponent("ScrollingText", ScrollingText, {
	text = "string",
	width = "number",
	speed = "number",
})

--- @type ascii-ui.FunctionalComponent
local App = ui.createComponent("App", function()
	return {
		Paragraph({ content = "=== Station Board ===" }),
		Paragraph({ content = "" }), -- empty line
		ScrollingTextComponent({
			text = "Next station: Central Station - Departure in 5 minutes",
			width = 60,
			speed = 150,
		}),
		Paragraph({ content = "" }), -- empty line
		ScrollingTextComponent({
			text = "Important announcement: Service is operating normally",
			width = 60,
			speed = 120,
		}),
		Paragraph({ content = "" }), -- empty line
		ScrollingTextComponent({
			text = "Schedule: Monday to Friday 6:00 - 23:00 | Saturday and Sunday 7:00 - 22:00",
			width = 60,
			speed = 100,
		}),
	}
end)

ui.mount(App)
