local Element = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")

--- @alias ascii-ui.ParagraphComponent.Props { content?: string }

--- @param props ascii-ui.ParagraphComponent.Props
--- @return fun(): ascii-ui.BufferLine[]
local function Paragraph(props)
	return function()
		return { Element:new({ content = props.content }):wrap() }
	end
end

return createComponent("Paragraph", Paragraph, { content = "string" })
