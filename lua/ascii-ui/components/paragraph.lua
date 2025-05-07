local Component = require("ascii-ui.components.component")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")

--- @alias ascii-ui.ParagraphComponent.Props { content?: ascii-ui.ComponentProp<string> }

---@class ascii-ui.ParagraphComponent : ascii-ui.Component
---@field content string
local Paragraph = {
	__name = "ParagraphComponent",
}

---@param props? ascii-ui.ParagraphComponent.Props
---@return ascii-ui.ParagraphComponent
function Paragraph:new(props)
	props = props or {}
	local state = {
		content = props.content or "",
	}
	return Component:extend(self, state)
end

---@return ascii-ui.BufferLine[]
function Paragraph:render()
	return { Element:new(self.content):wrap() }
end

--- @param props ascii-ui.ParagraphComponent.Props
--- @return fun(): ascii-ui.BufferLine[]
function Paragraph.fun(props)
	local content = function()
		return type(props.content) == "string" and props.content or props.content()
	end
	return function()
		local component = Paragraph:new({ content = content() })
		return component:render()
	end
end

return Paragraph
