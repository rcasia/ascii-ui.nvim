local Component = require("ascii-ui.components.component")

---@class ascii-ui.TextInput : ascii-ui.Component
---@field content string
local TextInput = {}

---@return ascii-ui.TextInput
function TextInput:new(content)
	return Component:extend(self, { content = content })
end

return TextInput
