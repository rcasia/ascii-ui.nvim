local interaction_type = require("ascii-ui.interaction_type")

--- @class ascii-ui.SegmentOpts
--- @field content string does not support newlines
--- @field is_focusable? boolean whether the segment can be focused
--- @field interactions? table<ascii-ui.UserInteractions.InteractionType, function> a map of interaction types to functions
--- @field highlight? string a highlight group name to apply to the segment

---
--- A segment is the minimal unit of a render in ascii-ui.
--- It contains the content to be displayed, optional interactions, and can be highlighted.
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
	assert(type(props) == "table", "Element props must be a table. Found: " .. type(props) .. " " .. debug.traceback())

	vim.validate({ content = { props.content, "string" } })

	-- content cannot have newlines
	assert(not props.content:find("\n", 1, true), "Segment content cannot contain newlines. Found: " .. props.content)

	local state = {
		id = generate_id(),
		content = props.content,
		highlight = props.highlight,
		focusable = props.is_focusable or false,
		interactions = props.interactions or {},
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

--- @param obj any
function Segment.is_segment(obj)
	if
		type(obj) == "table"
		--
		and obj.__index == Segment.__index
	then
		return true
	end

	return false
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
	if self.focusable then
		return true
	end

	return vim.tbl_count(self.interactions) > 0
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
