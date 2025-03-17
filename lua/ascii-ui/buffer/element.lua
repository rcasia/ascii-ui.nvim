---@class ascii-ui.Element
local Element = {}

local last_incremental_id = 0
local function generate_id()
	last_incremental_id = last_incremental_id + 1
	return last_incremental_id
end

---@param text string
---@param is_focusable? boolean
---@return ascii-ui.Element
function Element:new(text, is_focusable)
	vim.validate({ text = { text, "string" } })
	local state = {
		id = generate_id(),
		text = text,
		focusable = is_focusable or false,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@return integer
function Element:len()
	return string.len(self.text)
end

function Element:to_string()
	return self.text
end

function Element:is_focusable()
	return self.focusable
end

return Element
