local Element = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")

--- @alias ascii-ui.ParagraphComponent.Props { content?: ascii-ui.ComponentProp<string> }

--- @param props ascii-ui.ParagraphComponent.Props
--- @return fun(): ascii-ui.BufferLine[]
local function Paragraph(props)
	return function()
		local content = type(props.content) == "string" and props.content or props.content()

		return { Element:new(content):wrap() }
	end
end

return createComponent("Paragraph", Paragraph)
