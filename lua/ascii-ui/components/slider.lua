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
	props = props or {}

	return Component:extend(self, {})
end

function Slider:render()
	return {
		Bufferline:new(Element:new("+---------")),
	}
end

return Slider
