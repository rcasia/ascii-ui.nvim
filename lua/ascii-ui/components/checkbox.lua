local Component = require("ascii-ui.components.component")

---@class ascii-ui.Checkbox : ascii-ui.Component
local Checkbox = {}

---@param opts? { checked?: boolean, label?: string }
---@return ascii-ui.Checkbox
function Checkbox:new(opts)
	opts = opts or {}
	opts.checked = opts.checked or false
	opts.label = opts.label or ""
	opts.type = "checkbox"
	return Component:extend(self, opts)
end

function Checkbox:toggle()
	self.checked = not self.checked
end

function Checkbox:is_checked()
	return self.checked
end

return Checkbox
