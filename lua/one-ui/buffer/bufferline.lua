local Element = require("one-ui.buffer.element")

---@class one-ui.BufferLine
local BufferLine = {}

---@param ... one-ui.Element
---@return one-ui.BufferLine
function BufferLine:new(...)
	local elements = { ... }

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
	local found = vim.iter(self.elements):find(function(element)
		return element:is_focusable()
	end)
	return found, found and { col = 1 } or nil
end

---@param col number
---@return one-ui.Element | nil
function BufferLine:find_element_by_col(col)
	local len = 0
	for _, element in ipairs(self.elements) do
		len = len + element:len()
		if len >= col then
			return element
		end
	end

	return nil -- out of bounds
end

function BufferLine.from_string(str)
	return BufferLine:new(Element:new(str))
end

function BufferLine:to_string()
	return self.elements[1]:to_string()
end

return BufferLine
