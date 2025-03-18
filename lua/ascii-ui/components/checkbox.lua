local Component = require("ascii-ui.components.component")

---@class ascii-ui.Checkbox
local Checkbox = {}

---@param opts { active?: boolean, label?: boolean }
function Checkbox:new(opts)
	opts = opts or {}
	return Component:extend(self, {
		checked = opts.active or false,
		label = opts.label or "",
		type = "checkbox",
	})
end

function Checkbox:toggle()
	self.checked = not self.checked
end

function Checkbox:is_checked()
	return self.checked
end

return Checkbox
