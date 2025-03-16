local Element = require("one-ui.buffer.element")

---@class one-ui.BufferLine
local BufferLine = {}

---@param elements one-ui.Element
---@return one-ui.BufferLine
function BufferLine:new(elements)
	if vim.isarray(elements) == false then
		elements = { elements }
	end

	local state = {
		elements = elements,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@return one-ui.Element | nil
---@return { col: number } | nil
function BufferLine:find_focusable()
	assert(self.elements, "bufferline component failed: element cannot be nil")
	if not self.elements[1]:is_focusable() then
		return nil, nil
	end
	return self.elements[1], { col = 1 }
end

function BufferLine.from_string(str)
	return BufferLine:new(Element:new(str))
end

function BufferLine:to_string()
	return self.elements[1]:to_string()
end

return BufferLine
