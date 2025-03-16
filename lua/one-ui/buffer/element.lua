---@class one-ui.Element
local Element = {}

function Element:new(text)
	local state = {
		text = text,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

function Element:to_string()
	return self.text
end

return Element
