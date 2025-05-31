local interaction_type = require("ascii-ui.interaction_type")

---@alias ascii-ui.SegmentOpts { content: string, is_focusable?: boolean, interactions?: table<ascii-ui.UserInteractions.InteractionType, function>, highlight?: string }

---@class ascii-ui.Segment
---@field content string
---@field interactions table<ascii-ui.UserInteractions.InteractionType, function>
---@field highlight? string
---@field private focusable boolean
local Segment = {}

local last_incremental_id = 0
local function generate_id()
	last_incremental_id = last_incremental_id + 1
	return last_incremental_id
end

local function unicode_len(s)
	local i, len = 1, 0
	while i <= #s do
		local c = s:byte(i)
		if c < 0x80 then
			i = i + 1
		elseif c < 0xE0 then
			i = i + 2
		elseif c < 0xF0 then
			i = i + 3
		else
			i = i + 4
		end
		len = len + 1
	end
	return len
end

---@param ... ascii-ui.SegmentOpts  | string
---@return ascii-ui.Segment
function Segment:new(...)
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

	return state
end

---@return integer
function Segment:len()
	return unicode_len(self.content)
end

function Segment:to_string()
	return self.content
end

---@return boolean
function Segment:is_focusable()
	return self.focusable
end

function Segment:is_colored()
	return self.highlight ~= nil
end

function Segment:is_inputable()
	return self.interactions[interaction_type.ON_INPUT] ~= nil
end

--- Wraps the element in a ascii-ui.Bufferline object
---@return ascii-ui.BufferLine
function Segment:wrap()
	local Bufferline = require("ascii-ui.buffer.bufferline")
	return Bufferline.new(self)
end

return Segment
