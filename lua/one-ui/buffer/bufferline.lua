---@class one-ui.BufferLine
local BufferLine = {}

---@param text string
function BufferLine:new(text)
	local state = {
		text = text,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

return BufferLine
