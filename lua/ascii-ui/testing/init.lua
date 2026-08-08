local EventBus = require("ascii-ui.events")
local fiber = require("ascii-ui.fiber")
local interaction_type = require("ascii-ui.interaction_type")

--- @class ascii-ui.testing.Screen
--- @field private _fiber_root ascii-ui.RootFiberNode
--- @field private _bus ascii-ui.EventBus
--- @tag ascii-ui.testing.Screen
local Screen = {}
Screen.__index = Screen

--- @param component ascii-ui.FunctionalComponent
--- @return ascii-ui.testing.Screen
--- @tag ascii-ui.testing.render()
local function render(component)
	local bus = EventBus.new()
	local fiber_root = fiber.render(component)
	fiber_root.bus = bus

	return setmetatable({
		_fiber_root = fiber_root,
		_bus = bus,
	}, Screen)
end

--- @private
--- @return ascii-ui.Buffer
function Screen:_get_buffer()
	return self._fiber_root:get_buffer()
end

--- @private
function Screen:_rerender()
	self._fiber_root = fiber.rerender(self._fiber_root)
	self._fiber_root.bus = self._bus
end

--- @param text string
--- @return ascii-ui.Segment | nil
function Screen:getByText(text)
	local buffer = self:_get_buffer()
	for _, line in ipairs(buffer.lines) do
		for _, segment in ipairs(line.segments) do
			if segment.content:find(text, 1, true) then
				return segment
			end
		end
	end
	error(("Text not found: %s"):format(text))
end

--- @param text string
--- @return ascii-ui.Segment[]
function Screen:getAllByText(text)
	local buffer = self:_get_buffer()
	local results = {}
	for _, line in ipairs(buffer.lines) do
		for _, segment in ipairs(line.segments) do
			if segment.content:find(text, 1, true) then
				table.insert(results, segment)
			end
		end
	end
	return results
end

--- @param text string
--- @return ascii-ui.Segment | nil
function Screen:queryByText(text)
	local buffer = self:_get_buffer()
	for _, line in ipairs(buffer.lines) do
		for _, segment in ipairs(line.segments) do
			if segment.content:find(text, 1, true) then
				return segment
			end
		end
	end
	return nil
end

--- @param highlight string
--- @return ascii-ui.Segment | nil
function Screen:getByHighlight(highlight)
	local buffer = self:_get_buffer()
	for _, line in ipairs(buffer.lines) do
		for _, segment in ipairs(line.segments) do
			if segment.highlight == highlight then
				return segment
			end
		end
	end
	error(("Highlight not found: %s"):format(highlight))
end

--- @return ascii-ui.Segment
function Screen:getFocusable()
	local buffer = self:_get_buffer()
	local focusable = buffer:iter_focusables()()
	if not focusable then
		error("No focusable segments found")
	end
	return focusable
end

--- @return ascii-ui.Segment[]
function Screen:getAllFocusable()
	local buffer = self:_get_buffer()
	local results = {}
	for focusable in buffer:iter_focusables() do
		table.insert(results, focusable)
	end
	return results
end

--- @param text string
--- @return boolean
function Screen:hasText(text)
	local buffer = self:_get_buffer()
	for _, line in ipairs(buffer:to_lines()) do
		if line:find(text, 1, true) then
			return true
		end
	end
	return false
end

--- @param line string
--- @return boolean
function Screen:hasLine(line)
	local buffer = self:_get_buffer()
	local lines = buffer:to_lines()
	for _, l in ipairs(lines) do
		if l == line then
			return true
		end
	end
	return false
end

--- @param expected_lines string[]
--- @return boolean
function Screen:hasLines(expected_lines)
	local buffer = self:_get_buffer()
	local actual_lines = buffer:to_lines()
	if #actual_lines ~= #expected_lines then
		return false
	end
	for i, line in ipairs(expected_lines) do
		if actual_lines[i] ~= line then
			return false
		end
	end
	return true
end

--- @param text string
--- @return boolean
function Screen:hasFocusable(text)
	local buffer = self:_get_buffer()
	for focusable in buffer:iter_focusables() do
		if focusable.content:find(text, 1, true) then
			return true
		end
	end
	return false
end

--- @param highlight string
--- @return boolean
function Screen:hasHighlight(highlight)
	local buffer = self:_get_buffer()
	for _, line in ipairs(buffer.lines) do
		for _, segment in ipairs(line.segments) do
			if segment.highlight == highlight then
				return true
			end
		end
	end
	return false
end

--- @return string[]
function Screen:toLines()
	return self:_get_buffer():to_lines()
end

--- @return string
function Screen:toSnapshot()
	return self:_get_buffer():to_string()
end

--- @param text string
function Screen:select(text)
	local segment = self:getByText(text)
	if not segment.interactions[interaction_type.SELECT] then
		error(("Segment '%s' does not have SELECT interaction"):format(text))
	end
	segment.interactions[interaction_type.SELECT]()
	self:_rerender()
end

--- @param text string
--- @param interaction string
function Screen:trigger(text, interaction)
	local segment = self:getByText(text)
	if not segment.interactions[interaction] then
		error(("Segment '%s' does not have %s interaction"):format(text, interaction))
	end
	segment.interactions[interaction]()
	self:_rerender()
end

--- @param text string
function Screen:focus(text)
	local buffer = self:_get_buffer()
	for focusable in buffer:iter_focusables() do
		if focusable.content:find(text, 1, true) then
			return
		end
	end
	error(("Focusable with text not found: %s"):format(text))
end

return {
	render = render,
	Screen = Screen,
}
