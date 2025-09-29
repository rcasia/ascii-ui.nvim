local Segment = require("ascii-ui.buffer.segment")

---@class ascii-ui.BufferLine
---@field segments ascii-ui.Segment[]
local BufferLine = {}
BufferLine.__index = BufferLine

---@param ... ascii-ui.Segment | boolean
---@return ascii-ui.BufferLine
function BufferLine.new(...)
	local segments = vim.iter({ ... })
		:filter(function(segment)
			return type(segment) == "table"
		end)
		:totable()

	local state = {
		segments = segments,
	}

	setmetatable(state, BufferLine)

	return state
end

--- @param obj any
function BufferLine.is_bufferline(obj)
	if
		type(obj) == "table"
		--
		and obj.__index == BufferLine.__index
	then
		return true
	end

	return false
end

---@return number[] cols
function BufferLine:find_focusable()
	assert(self.segments, "bufferline component failed: segment cannot be nil")

	local col = 0
	local cols = {}
	---@param segment ascii-ui.Segment
	vim.iter(self.segments):each(function(segment)
		if segment:is_focusable() then
			cols[#cols + 1] = col
		end
		col = col + segment:len()
	end)

	return cols
end
---@param col number
---@return ascii-ui.Segment | nil
function BufferLine:find_segment_by_col(col)
	local len = 0
	for _, segment in ipairs(self.segments) do
		len = len + segment:len()
		if len > col then
			return segment
		end
	end

	return nil -- out of bounds
end

---@return integer length
function BufferLine:len()
	return vim.iter(self.segments):fold(0, function(acc, segment)
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
		.iter(self.segments)
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
	assert(
		BufferLine.is_bufferline(other_bufferline),
		("other_bufferline should be of type bufferline but found  %s : %s"):format(
			type(other_bufferline),
			vim.inspect(other_bufferline)
		)
	)

	local segments = self.segments

	if delimiter then
		segments[#segments + 1] = delimiter
	end
	vim.iter(other_bufferline.segments):each(function(segment)
		segments[#segments + 1] = segment
	end)

	return BufferLine.new(unpack(segments))
end

--- @return boolean
function BufferLine:is_empty()
	return #self.segments == 0
end

--- @return { segment: ascii-ui.Segment, position: ascii-ui.Position }[]
function BufferLine:focusable_segments(from_line)
	local col = 0
	return vim.iter(self.segments)
		:map(function(segment)
			local current_col = col
			col = col + segment:len()
			return { segment = segment, position = { line = from_line, col = current_col } }
		end)
		:filter(function(result)
			return result.segment:is_focusable()
		end)
		:totable()
end

return BufferLine
