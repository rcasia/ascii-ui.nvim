---@class ascii-ui.Element
---@field interactions table<string, function>
---@field len fun(): integer
---@field highlight string
---@private focusable boolean
local Element = {}

local last_incremental_id = 0
local function generate_id()
	last_incremental_id = last_incremental_id + 1
	return last_incremental_id
end

---@param text string
---@param is_focusable? boolean
---@return ascii-ui.Element
function Element:new(text, is_focusable, interactions, highlight)
	vim.validate({ text = { text, "string" } })
	local state = {
		id = generate_id(),
		text = text,
		highlight = highlight,
		focusable = is_focusable or false,
		interactions = interactions or {
			on_select = function()
				print("selected", text)
			end,
		}, -- TODO: pass this to default interactions on a different module
	}

	setmetatable(state, self)
	self.__index = self

	---@cast state ascii-ui.Element
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
