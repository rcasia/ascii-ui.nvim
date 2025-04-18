local Element = require("ascii-ui.buffer.element")

---@class ascii-ui.BufferLine
---@field elements ascii-ui.Element[]
local BufferLine = {}

---@param ... ascii-ui.Element
---@return ascii-ui.BufferLine
function BufferLine:new(...)
	local elements = { ... }

	local state = {
		elements = elements,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@deprecated
---@return ascii-ui.Element | nil
---@return number col returns 0 when not found
function BufferLine:find_focusable()
	assert(self.elements, "bufferline component failed: element cannot be nil")

	local col = 1
	---@param element ascii-ui.Element
	local found = vim.iter(self.elements):find(function(element)
		if element:is_focusable() == false then
			col = col + element:len()
		end
		return element:is_focusable()
	end)

	return found, found and col or 0
end

---@return number col returns 0 when not found
function BufferLine:find_focusable2()
	assert(self.elements, "bufferline component failed: element cannot be nil")

	local col = 1
	---@param element ascii-ui.Element
	local found = vim.iter(self.elements):find(function(element)
		if element:is_focusable() == false then
			col = col + element:len()
		end
		return element:is_focusable()
	end)

	return found and col or 0
end
---@param col number
---@return ascii-ui.Element | nil
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

---@return integer length
function BufferLine:len()
	return vim.iter(self.elements):fold(0, function(acc, element)
		return acc + element:len()
	end)
end

---@param str string
function BufferLine.from_string(str)
	return BufferLine:new(Element:new(str))
end

---@return string
function BufferLine:to_string()
	return vim
		.iter(self.elements)
		---@param element ascii-ui.Element
		:map(function(element)
			return element:to_string()
		end)
		:join("")
end

return BufferLine
