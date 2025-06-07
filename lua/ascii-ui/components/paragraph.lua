local Element = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")

--- @alias ascii-ui.ParagraphComponent.Props { content?: string }

--- @param props ascii-ui.ParagraphComponent.Props
--- @return ascii-ui.BufferLine[]
local function Paragraph(props)
	return { Element:new({ content = props.content }):wrap() }
end

return createComponent("Paragraph", Paragraph, { content = "string" })
