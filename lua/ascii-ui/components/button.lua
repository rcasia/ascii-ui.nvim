local Component = require("ascii-ui.components.component")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local highlights = require("ascii-ui.highlights")

--- @alias ascii-ui.ButtonComponent.Props { label: string }

---@class ascii-ui.ButtonComponent : ascii-ui.Component
---@field label string
local Button = {
	__name = "ButtonComponent",
}

---@param props ascii-ui.ButtonComponent.Props
---@return ascii-ui.ButtonComponent
function Button:new(props)
	props = props or {}
	local state = {
		label = props.label or "",
	}
	return Component:extend(self, state)
end

---@return ascii-ui.BufferLine[]
function Button:render()
	return { Bufferline:new(Element:new({ content = self.label, highlight = highlights.BUTTON })) }
end

return Button
