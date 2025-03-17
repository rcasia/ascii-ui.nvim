---@class ascii-ui.Checkbox
local Checkbox = {}

---@param opts { active?: boolean }
function Checkbox:new(opts)
	opts = opts or {}
	local checkbox = {
		checked = opts.active or false,
		label = opts.label or "",
		type = "checkbox",
	}

	setmetatable(checkbox, self)
	self.__index = self

	return checkbox
end

function Checkbox:toggle()
	self.checked = not self.checked
end

function Checkbox:is_checked()
	return self.checked
end

return Checkbox
