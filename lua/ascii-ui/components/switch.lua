local Component = require("ascii-ui.components.component")

---@class ascii-ui.Switch : ascii-ui.Component
local Switch = {}

---@return ascii-ui.TextInput
function Switch:new()
	return Component:extend(self, {})
end

return Switch
