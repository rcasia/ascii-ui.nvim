local Element = require("one-ui.buffer.element")

---@class one-ui.BufferLine
local BufferLine = {}

---@param element one-ui.Element
---@return one-ui.BufferLine
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
---@return { col: number } | nil
function BufferLine:find_focusable()
	assert(self.element, "bufferline component failed: element cannot be nil")
	if not self.element:is_focusable() then
		return nil, nil
	end
	return self.element, { col = 1 }
end

function BufferLine.from_string(str)
	return BufferLine:new(Element:new(str))
end

function BufferLine:to_string()
	return self.element:to_string()
end

return BufferLine
