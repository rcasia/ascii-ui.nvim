local interaction_type = require("ascii-ui.interaction_type")

---@alias ascii-ui.ElementProps { content: string, is_focusable?: boolean, interactions?: table<string, function>, highlight?: string }

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

---@param ... ascii-ui.ElementProps  | string
---@return ascii-ui.Element
function Element:new(...)
	local props = { ... }

	if type(props[1]) == "string" then
		props = { content = props[1], is_focusable = props[2], interactions = props[3], highlight = props[4] }
	else
		props = props[1]
	end
	assert(type(props) == "table", "Element props must be a table")

	vim.validate({ content = { props.content, "string" } })
	local state = {
		id = generate_id(),
		content = props.content,
		highlight = props.highlight,
		focusable = props.is_focusable or false,
		interactions = props.interactions or {
			[interaction_type.SELECT] = function()
				print("selected", props.content)
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
	return string.len(self.content)
end

function Element:to_string()
	return self.content
end

---@return boolean
function Element:is_focusable()
	return self.focusable
end

function Element:is_colored()
	return self.highlight ~= nil
end

return Element
