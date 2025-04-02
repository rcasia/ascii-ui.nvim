local Component = require("ascii-ui.components.component")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local interaction_type = require("ascii-ui.interaction_type")

---@class ascii-ui.Slider : ascii-ui.Component
local Slider = {
	__name = "SliderComponent",
}

---@return ascii-ui.Slider
function Slider:new()
	local state = {
		value = 0,
	}

	return Component:extend(self, state)
end

function Slider:move_right()
	self.value = self.value + 10
end

function Slider:move_left()
	self.value = self.value - 10
end

---@param value integer
function Slider:slide_to(value)
	self.value = value
end

---@return ascii-ui.Bufferline[]
function Slider:render()
	local interactions = {
		[interaction_type.CURSOR_MOVE_RIGHT] = function()
			self:move_right()
		end,
		[interaction_type.CURSOR_MOVE_LEFT] = function()
			self:move_left()
		end,
	}

	if self.value == 0 then
		return {
			Bufferline:new(Element:new("+---------", false, interactions)),
		}
	end

	local width = 10
	local knob_position = math.floor(width * self.value / 100)
	local line = string.rep("-", knob_position - 1) .. "+" .. string.rep("-", width - knob_position)

	return {
		Bufferline:new(Element:new(line, false, interactions)),
	}
end

return Slider
