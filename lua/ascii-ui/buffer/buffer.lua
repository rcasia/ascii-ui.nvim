local BufferLine = require("ascii-ui.buffer.bufferline")

---@class ascii-ui.Buffer
---@field id string
---@field lines ascii-ui.BufferLine[]
local Buffer = {}

local last_incremental_id = 0
local function generate_id()
	last_incremental_id = last_incremental_id + 1
	return last_incremental_id
end

---@param ...? ascii-ui.BufferLine
---@return ascii-ui.Buffer
function Buffer:new(...)
	local lines = { ... }
	local state = {
		id = generate_id(),
		lines = lines or {},
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@return ascii-ui.Element | nil
function Buffer:find_focusable()
	assert(self.lines, "buffer component failed: lines cannot be nil")

	local result
	for i, line in ipairs(self.lines) do
		result = { line:find_focusable() }
		if result[1] then
			return result[1], { line = i, col = result[2].col }
		end
	end
	return result[1], result[2]
end

---@return fun(): ascii-ui.Element | nil
function Buffer:iter_focusables()
	assert(self.lines, "buffer component failed: lines cannot be nil")

	local iter = vim.iter(self.lines)
		:map(function(line)
			return vim.iter(line.elements)
				:filter(function(element)
					return element:is_focusable()
				end)
				:totable()
		end)
		:flatten()
	return function()
		return iter:next()
	end
end

---@param lines string[]
---@return ascii-ui.Buffer
function Buffer.from_lines(lines)
	local bufferlines = vim.iter(lines)
		:map(function(line)
			return BufferLine.from_string(line)
		end)
		:totable()
	return Buffer:new(unpack(bufferlines))
end

---@return string[]
function Buffer:to_lines()
	return vim.iter(self.lines)
		:map(function(line)
			return line:to_string()
		end)
		:totable()
end

---@param id string
---@return ascii-ui.Element | nil
function Buffer:find_element_by_id(id)
	return vim.iter(self.lines)
		:map(function(line)
			return vim.iter(line.elements):find(function(element)
				return element.id == id
			end)
		end)
		:take(1)
		:last()
end

---@param position { line: integer, col: integer }
---@return ascii-ui.Element | nil
function Buffer:find_element_by_position(position)
	return self.lines[position.line]:find_element_by_col(position.col)
end

return Buffer
