local BufferLine = require("ascii-ui.buffer.bufferline")
local logger = require("ascii-ui.logger")

---@alias ascii-ui.Position { line: integer, col: integer }
---@alias ascii-ui.Buffer.ElementFoundResult { element: ascii-ui.Element, position: ascii-ui.Position }

---@class ascii-ui.Buffer
---@field lines ascii-ui.BufferLine[]
local Buffer = {}
Buffer.__index = Buffer

---@param ...? ascii-ui.BufferLine
---@return ascii-ui.Buffer
function Buffer.new(...)
	local lines = { ... }
	local state = {
		lines = lines or {},
	}

	setmetatable(state, Buffer)

	return state
end

---@return integer width
function Buffer:width()
	return vim.iter(self.lines)
		:map(function(line)
			return line:len()
		end)
		:fold(0, math.max)
end

function Buffer:height()
	return #self.lines
end

---@param position? ascii-ui.Position
---@return { found: boolean, pos: ascii-ui.Position }
function Buffer:find_next_focusable(position)
	logger.debug("find_next_focusable: " .. vim.inspect(position))
	position = position or {}
	position = { line = position.line or 1, col = position.col or 0 }

	local pos = vim
		.iter(self.lines)
		:skip(position.line - 1)
		:enumerate()
		--- @param line ascii-ui.BufferLine
		:map(function(index, line)
			return line:focusable_segments(index)
		end)
		:flatten()
		:map(function(result)
			logger.debug("considering position: (%d, %d)", result.position.line, result.position.col)
			return result.position
		end)
		:filter(function(p)
			if p.line == position.line and p.col <= position.col then
				return false
			end
			return true
		end)
		:take(1)
		:last()

	return { pos = pos or position, found = pos ~= nil }
end

---@param position ascii-ui.Position
---@return { found: boolean, pos: ascii-ui.Position }
function Buffer:find_last_focusable(position)
	logger.debug("find_last_focusable: " .. vim.inspect(position))
	if position.line <= 0 then
		return { pos = position, found = false }
	end

	local pos = vim
		.iter(self.lines)
		:enumerate()
		:rev()
		:skip(math.abs(#self.lines - position.line))
		--- @param line ascii-ui.BufferLine
		:map(function(index, line)
			return vim.iter(line:focusable_segments(index)):rev():totable()
		end)
		:flatten()
		:map(function(result)
			return result.position
		end)
		:map(function(o)
			logger.debug("considering position: (%d, %d)", o.line, o.col)
			return o
		end)
		:filter(function(p)
			if p.line == position.line and p.col >= position.col then
				logger.debug("filtering out position: (%d, %d)", p.line, p.col)
				return false
			end
			return true
		end)
		:take(1)
		:last() or {}

	logger.debug("last focusable position: " .. vim.inspect(pos))

	return {
		pos = { line = pos.line or position.line, col = pos.col or position.col },
		found = (pos.line and pos.col) ~= nil,
	}
end

---@return fun(): ascii-ui.Segment | nil
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
	return Buffer.new(unpack(bufferlines))
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

--- @param ... ascii-ui.BufferLine
--- @return ascii-ui.Buffer
function Buffer:add(...)
	local lines = { ... }
	if #lines == 0 then
		return self
	end

	vim.list_extend(self.lines, lines)
	return self
end

return Buffer
