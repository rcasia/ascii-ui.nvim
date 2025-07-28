local Element = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.create-component")

--- @alias ascii-ui.ParagraphComponent.Props { content?: string }

--- @param props ascii-ui.ParagraphComponent.Props
--- @return ascii-ui.BufferLine[]
local function Paragraph(props)
	return vim.iter(vim.split(props.content or "", "\n", { plain = true }))
		:map(function(line)
			return Element:new({ content = line }):wrap()
		end)
		:totable()
end

return createComponent("Paragraph", Paragraph, { content = "string" })
