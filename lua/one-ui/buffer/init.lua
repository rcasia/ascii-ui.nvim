local BufferLine = require("one-ui.buffer.bufferline")

---@class one-ui.Buffer
local Buffer = {}

---@param lines? one-ui.BufferLine[]
function Buffer:new(lines)
	local state = {
		lines = lines or {},
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@param lines string[]
---@return one-ui.Buffer
function Buffer.from_lines(lines)
	local bufferlines = vim.iter(lines)
		:map(function(line)
			return BufferLine:new(line)
		end)
		:totable()
	return Buffer:new(bufferlines)
end

---@return string[]
function Buffer:to_lines()
	return vim.iter(self.lines)
		:map(function(line)
			return line.text
		end)
		:totable()
end

return Buffer
