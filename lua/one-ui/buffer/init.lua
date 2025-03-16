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

---@return one-ui.Element | nil
function Buffer:find_focusable()
	assert(self.lines, "buffer component failed: lines cannot be nil")

	return vim.iter(self.lines)
		:map(function(line)
			return line:find_focusable()
		end)
		:nth(1)
end

---@param lines string[]
---@return one-ui.Buffer
function Buffer.from_lines(lines)
	local bufferlines = vim.iter(lines)
		:map(function(line)
			return BufferLine.from_string(line)
		end)
		:totable()
	return Buffer:new(bufferlines)
end

---@return string[]
function Buffer:to_lines()
	return vim.iter(self.lines)
		:map(function(line)
			return line:to_string()
		end)
		:totable()
end

return Buffer
