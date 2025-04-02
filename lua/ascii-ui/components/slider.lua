local Component = require("ascii-ui.components.component")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")

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

---@return ascii-ui.Bufferline[]
function Slider:render()
	local interactions = {
		on_select = function()
			self:move_right()
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

---@param value integer
function Slider:slide_to(value)
	self.value = value
end

return Slider
