local Checkbox = {}

function Checkbox:new()
	local checkbox = {
		checked = false,
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
