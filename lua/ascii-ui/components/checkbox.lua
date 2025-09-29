local Segment = require("ascii-ui.buffer.segment")
local createComponent = require("ascii-ui.components.create-component")

---@param props { active?: boolean, label?: string }
local function Checkbox(props)
	return { Segment:new(("[%s] %s"):format(props.active and "x" or " ", props.label or "")):wrap() }
end

return createComponent("Checkbox", Checkbox, { active = "boolean", label = "string" })
