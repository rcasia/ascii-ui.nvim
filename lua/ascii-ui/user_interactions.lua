local logger = require("ascii-ui.logger")

---@class ascii-ui.UserInteractions
---@field private singleton_instance ascii-ui.UserInteractions | nil
---@field private buffers table<integer, ascii-ui.Buffer>
local UserInteractions = {
	singleton_instance = nil,
}

function UserInteractions.instance()
	if UserInteractions.singleton_intance then
		return UserInteractions.singleton_intance
	end

	UserInteractions.singleton_intance = UserInteractions:new()
	return UserInteractions.singleton_intance
end

---@return ascii-ui.UserInteractions
function UserInteractions:new()
	local state = {
		buffers = {},
	}
	setmetatable(state, self)
	self.__index = self

	return state
end

---@alias ascii-ui.UserInteractions.InteractionOpts { buffer_id: integer, position: ascii-ui.Position, interaction_type: ascii-ui.UserInteractions.InteractionType | string }
---@param opts ascii-ui.UserInteractions.InteractionOpts
function UserInteractions:interact(opts)
	assert(opts.buffer_id, "buffer_id cannot be nil")
	local buffer = self.buffers[opts.buffer_id]
	if not buffer then
		return -- buffer has not been found
	end

	local segment = buffer:find_segment_by_position(opts.position)

	if not segment then
		logger.warn(
			"segment not found in buffer by position (%d, %d) and buffer dimensions being %d x %d",
			opts.position.line,
			opts.position.col,
			buffer:height(),
			buffer:width()
		)
		return -- there is no segment to interact with
	end

	assert(opts.interaction_type, "interaction type cannot be nil")

	local interaction_function = segment.interactions[opts.interaction_type]
	if type(interaction_function) == "function" then
		interaction_function()
	end
end

---@param buffer ascii-ui.Buffer
---@param buffer_id integer
function UserInteractions:attach_buffer(buffer, buffer_id)
	self.buffers[buffer_id] = buffer
end

---@param buffer_id integer
function UserInteractions:detach_buffer(buffer_id)
	self.buffers[buffer_id] = nil
end

return UserInteractions
