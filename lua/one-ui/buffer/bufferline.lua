local Element = require("one-ui.buffer.element")

---@class one-ui.BufferLine
local BufferLine = {}

---@param element one-ui.Element
function BufferLine:new(element)
	local state = {
		element = element,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

function BufferLine.from_string(str)
	return BufferLine:new(Element:new(str))
end

function BufferLine:to_string()
	return self.element:to_string(self)
end

return BufferLine
