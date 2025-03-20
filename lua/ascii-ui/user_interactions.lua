---@class ascii-ui.UserInteractions
---@field private buffers table<integer, ascii-ui.Buffer>
local UserInteractions = {}

-- to know in what buffer id the user is interacting
-- and call the buffer-bufferline-element interaction function
-- so we need to attach the buffer to the user interactions
-- by first storing the buffer in table<buffer_id, buffer>
-- then we use a function to look for the buffer_id, search for the element interacted
-- and call the interaction function

---@return ascii-ui.UserInteractions
function UserInteractions:new()
	local state = {
		buffers = {},
	}
	setmetatable(state, self)
	self.__index = self
	return state
end

---@alias ascii-ui.UserInteractions.InteractionOpts { buffer_id: integer, position: table, interaction_type: ascii-ui.UserInteractions.InteractionType }
---@param opts ascii-ui.UserInteractions.InteractionOpts
function UserInteractions:interact(opts)
	local buffer = self.buffers[opts.buffer_id]
	local element = buffer:find_element_by_position(opts.position)
	assert(opts.interaction_type, "interaction type cannot be nil")
	assert(element.interactions[opts.interaction_type], "interaction type does not exist: " .. opts.interaction_type)()
end

---@param buffer ascii-ui.Buffer
function UserInteractions:attach_buffer(buffer)
	self.buffers[buffer.id] = buffer
end

---@param buffer_id integer
---@param position { line: integer, col: integer }
---@return ascii-ui.Element | nil
function UserInteractions:find_position_in_buffer(buffer_id, position)
	-- return self.buffers[buffer_id]
end

return UserInteractions
