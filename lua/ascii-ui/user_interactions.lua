---@class ascii-ui.UserInteractions
---@field private buffers table<integer, ascii-ui.Buffer>
local UserInteractions = {}

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

	if not element then
		return -- there is no element to interact with
	end

	assert(opts.interaction_type, "interaction type cannot be nil")

	local interaction_function = assert(
		element.interactions[opts.interaction_type],
		"interaction type does not exist: " .. opts.interaction_type
	)
	interaction_function()
end

---@param buffer ascii-ui.Buffer
function UserInteractions:attach_buffer(buffer)
	self.buffers[buffer.id] = buffer
end

return UserInteractions
