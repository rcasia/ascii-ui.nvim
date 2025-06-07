local Element = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")

---@param props { active?: boolean, label?: string }
local function Checkbox(props)
	return function()
		return { Element:new(("[%s] %s"):format(props.active and "x" or " ", props.label or "")):wrap() }
	end
end

return createComponent("Checkbox", Checkbox, { active = "boolean", label = "string" })
