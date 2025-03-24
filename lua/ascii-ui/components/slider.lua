local Component = require("ascii-ui.components.component")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")

---@class ascii-ui.Slider : ascii-ui.Component
local Slider = {
	__name = "SliderComponent",
}

---@param props? ascii-ui.BoxProps
---@return ascii-ui.Slider
function Slider:new(props)
	local state = {
		value = 0,
	}

	return Component:extend(self, state)
end

function Slider:render()
	if self.value == 0 then
		return {
			Bufferline:new(Element:new("+---------")),
		}
	end

	return {
		Bufferline:new(Element:new("---------+")),
	}
end

---@param value integer
function Slider:slide_to(value)
	self.value = value
end

return Slider
