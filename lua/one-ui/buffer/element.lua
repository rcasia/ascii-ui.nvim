---@class one-ui.Element
local Element = {}

---@param text string
---@param is_focusable? boolean
---@return one-ui.Element
function Element:new(text, is_focusable)
	vim.validate({ text = { text, "string" } })
	local state = {
		text = text,
		focusable = is_focusable or false,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

function Element:to_string()
	return self.text
end

function Element:is_focusable()
	return self.focusable
end

return Element
