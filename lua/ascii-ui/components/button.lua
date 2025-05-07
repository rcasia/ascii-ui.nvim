local Component = require("ascii-ui.components.component")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local highlights = require("ascii-ui.highlights")
local interaction_type = require("ascii-ui.interaction_type")

--- @alias ascii-ui.ButtonComponent.Props { label: string, on_press?: fun() }

---@class ascii-ui.ButtonComponent : ascii-ui.Component
--- @field label string
--- @field private on_press function
local Button = {
	__name = "ButtonComponent",
}

---@param props ascii-ui.ButtonComponent.Props
---@return ascii-ui.ButtonComponent
function Button:new(props)
	props = props or {}
	local state = {
		label = props.label or "",
		on_press = props.on_press,
	}
	return Component:extend(self, state)
end

---@return ascii-ui.BufferLine[]
function Button:render()
	return {
		Element:new({
			content = self.label,
			highlight = highlights.BUTTON,
			is_focusable = true,
			interactions = {
				[interaction_type.SELECT] = self.on_press,
			},
		}):wrap(),
	}
end

--- @param props ascii-ui.ButtonComponent.Props
--- @return fun(): ascii-ui.BufferLine[]
function Button.fun(props)
	return function()
		local label = type(props.label) == "function" and props.label() or props.label
		local on_press = props.on_press
		local button = Button:new({ label = label, on_press = on_press })
		return button:render()
	end
end

return Button.fun
