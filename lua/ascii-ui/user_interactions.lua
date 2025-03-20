local interaction_type = require("ascii-ui.interaction_type")
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

	-- initialize keymaps
	vim.keymap.set("n", "<CR>", function()
		local bufnr = 1 -- TODO: align buffer ids
		local cursor = vim.api.nvim_win_get_cursor(0)
		local position = { line = cursor[1], col = cursor[2] }

		UserInteractions:instance()
			:interact({ buffer_id = bufnr, position = position, interaction_type = interaction_type.SELECT })
	end, { noremap = true, silent = true })

	return state
end

---@alias ascii-ui.UserInteractions.InteractionOpts { buffer_id: integer, position: table, interaction_type: ascii-ui.UserInteractions.InteractionType | string }
---@param opts ascii-ui.UserInteractions.InteractionOpts
function UserInteractions:interact(opts)
	local buffer = self.buffers[opts.buffer_id]
	local element = buffer:find_element_by_position(opts.position)

	if not element then
		print("no se encontro el elemento en el buffer" .. vim.inspect(buffer))
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

-- return singleton for all the app
return UserInteractions
