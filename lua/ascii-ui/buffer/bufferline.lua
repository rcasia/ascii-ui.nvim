local Segment = require("ascii-ui.buffer.element")

---@class ascii-ui.BufferLine
---@field elements ascii-ui.Segment[]
local BufferLine = {}
BufferLine.__index = BufferLine

---@param ... ascii-ui.Segment | boolean
---@return ascii-ui.BufferLine
function BufferLine.new(...)
	local elements = vim.iter({ ... })
		:filter(function(segment)
			return type(segment) == "table"
		end)
		:totable()

	local state = {
		elements = elements,
	}

	setmetatable(state, BufferLine)

	return state
end

---@deprecated
---@return ascii-ui.Segment | nil
---@return number col returns 0 when not found
function BufferLine:find_focusable()
	assert(self.elements, "bufferline component failed: segement cannot be nil")

	local col = 1
	---@param segment ascii-ui.Segment
	local found = vim.iter(self.elements):find(function(segment)
		if segment:is_focusable() == false then
			col = col + segment:len()
		end
		return segment:is_focusable()
	end)

	return found, found and col or 0
end

---@return number col returns 0 when not found
function BufferLine:find_focusable2()
	assert(self.elements, "bufferline component failed: segment cannot be nil")

	local col = 0
	---@param segment ascii-ui.Segment
	local found = vim.iter(self.elements):find(function(segment)
		if segment:is_focusable() == false then
			col = col + segment:len()
		end
		return segment:is_focusable()
	end)

	return found and col or -1
end
---@param col number
---@return ascii-ui.Segment | nil
function BufferLine:find_element_by_col(col)
	local len = 0
	for _, segment in ipairs(self.elements) do
		len = len + segment:len()
		if len >= col then
			return segment
		end
	end

	return nil -- out of bounds
end

---@return integer length
function BufferLine:len()
	return vim.iter(self.elements):fold(0, function(acc, segment)
		return acc + segment:len()
	end)
end

---@param str string
function BufferLine.from_string(str)
	return BufferLine.new(Segment:new(str))
end

---@return string
function BufferLine:to_string()
	return vim
		.iter(self.elements)
		---@param segment ascii-ui.Segment
		:map(function(segment)
			return segment:to_string()
		end)
		:join("")
end

--- @param other_bufferline ascii-ui.BufferLine
--- @param delimiter? ascii-ui.Segment
--- @return ascii-ui.BufferLine
function BufferLine:append(other_bufferline, delimiter)
	assert(other_bufferline, "other_bufferline cannot be nil")

	local elements = self.elements

	if delimiter then
		elements[#elements + 1] = delimiter
	end
	vim.iter(other_bufferline.elements):each(function(segment)
		elements[#elements + 1] = segment
	end)

	return BufferLine.new(unpack(elements))
end

--- @return boolean
function BufferLine:is_empty()
	return #self.elements == 0
end

return BufferLine
