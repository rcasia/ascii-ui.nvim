local Component = require("ascii-ui.components.component")

---@class ascii-ui.TextInput : ascii-ui.Component
---@field content string
local TextInput = {
	__name = "TextInputComponent",
}

---@return ascii-ui.TextInput
function TextInput:new(content)
	return Component:extend(self, { content = content })
end

return TextInput
