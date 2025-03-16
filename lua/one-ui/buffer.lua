---@class one-ui.Buffer
local Buffer = {}

---@param lines? string[]
function Buffer:new(lines)
	local state = {
		lines = lines or {},
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@param lines string[]
function Buffer.from_lines(lines)
	return Buffer:new(lines)
end

---@return string[]
function Buffer:to_lines()
	return self.lines
end

return Buffer
