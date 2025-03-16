---@class one-ui.Element
local Element = {}

---@param text string
function Element:new(text)
	vim.validate({ text = { text, "string" } })
	local state = {
		text = text,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

function Element:to_string()
	return self.text
end

function Element:is_focusable()
	return true
end

return Element
