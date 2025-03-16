local Element = require("one-ui.buffer.element")

---@class one-ui.BufferLine
local BufferLine = {}

---@param element one-ui.Element
function BufferLine:new(element)
	vim.validate({ element = { element, "table" } })

	local state = {
		element = element,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@return one-ui.Element | nil
function BufferLine:find_focusable()
	assert(self.element, "bufferline component failed: element cannot be nil")
	return self.element:is_focusable() and self.element or nil
end

function BufferLine.from_string(str)
	return BufferLine:new(Element:new(str))
end

function BufferLine:to_string()
	return self.element:to_string()
end

return BufferLine
