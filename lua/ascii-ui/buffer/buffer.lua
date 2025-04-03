local BufferLine = require("ascii-ui.buffer.bufferline")

---@alias ascii-ui.Position { line: integer, col: integer }
---@alias ascii-ui.Buffer.ElementFoundResult { element: ascii-ui.Element, position: ascii-ui.Position }

---@class ascii-ui.Buffer
---@field lines ascii-ui.BufferLine[]
local Buffer = {}

---@param ...? ascii-ui.BufferLine
---@return ascii-ui.Buffer
function Buffer:new(...)
	local lines = { ... }
	local state = {
		lines = lines or {},
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@return integer width
function Buffer:width()
	return vim.iter(self.lines)
		:map(function(line)
			return line:len()
		end)
		:fold(0, function(acc, len)
			return math.max(acc, len)
		end)
end

function Buffer:height()
	return #self.lines
end

---@return ascii-ui.Element | nil
function Buffer:find_focusable()
	assert(self.lines, "buffer component failed: lines cannot be nil")

	local result
	for i, line in ipairs(self.lines) do
		result = { line:find_focusable() }
		if result[1] then
			return result[1], { line = i, col = result[2] }
		end
	end
	return result[1], result[2]
end

---@param position? ascii-ui.Position
---@return ascii-ui.Position
function Buffer:find_position_of_the_next_focusable(position)
	position = position or {}
	position = { line = position.line or 1, col = position.col or 1 }

	return vim
		.iter(ipairs(self.lines))
		:skip(position.line - 1)
		--- @param line ascii-ui.BufferLine
		:map(function(index, line)
			local _, col = line:find_focusable()
			if col == 0 then
				return position.line, nil, position.col -- return the current position when no focusable element is found
			end
			return index, line:find_focusable()
		end)
		:map(function(line_index, _, col)
			return { line = line_index, col = col }
		end)
		:filter(function(e)
			return e ~= nil
		end)
		:take(1)
		:last()
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

---@return fun(): ascii-ui.Buffer.ElementFoundResult | nil
function Buffer:iter_colored_elements()
	local iter = vim.iter(self.lines)
		:enumerate()
		:map(function(line_index, line)
			-- local line_index, line = indexed_line
			local col_offset = 1

			return vim.iter(line.elements)
				:map(function(element)
					local current_col = col_offset
					col_offset = col_offset + element:len() -- o el método que dé el ancho

					if element:is_colored() then
						return {
							element = element,
							position = { line = line_index, col = current_col },
						}
					else
						return nil
					end
				end)
				:filter(function(e)
					return e ~= nil
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
	return vim
		.iter(self.lines)
		:filter(function(item)
			return item ~= nil
		end)
		---@param line ascii-ui.BufferLine
		:map(function(line)
			return assert(line):to_string()
		end)
		:totable()
end

function Buffer:to_string()
	return vim.iter(self:to_lines()):join("\n")
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
	if not self.lines[position.line] then
		return nil -- out of bound
	end
	return self.lines[position.line]:find_element_by_col(position.col)
end

return Buffer
