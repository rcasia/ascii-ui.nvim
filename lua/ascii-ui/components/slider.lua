local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local interaction_type = require("ascii-ui.interaction_type")
local global_config = require("ascii-ui.config")
local useReducer = require("ascii-ui.hooks.use_reducer")

--- @param props? { title?: string, value?: integer, config?: ascii-ui.Config }
---@return ascii-ui.BufferLine[]
local function render(props)
	local _props, dispatch = useReducer(function(state, action)
		if action == "move_right" then
			state.value = math.min(state.value + 10, 100)
		end

		if action == "move_left" then
			state.value = math.max(state.value - 10, 0)
		end

		return state
	end, props)

	-- override default config
	local config = vim.tbl_extend("force", global_config, props.config)
	local cc = config.characters

	local interactions = {
		[interaction_type.CURSOR_MOVE_RIGHT] = function()
			dispatch("move_right")
		end,
		[interaction_type.CURSOR_MOVE_LEFT] = function()
			dispatch("move_left")
		end,
	}

	props = _props()

	local width = 10
	local knob_position = math.floor(width * props.value / 100)

	return {
		props.title ~= "" and Element:new(props.title, false):wrap() or nil,
		Bufferline:new(
			Element:new(cc.horizontal:rep(knob_position), false, interactions),
			Element:new(cc.thumb, true, interactions),
			Element:new(cc.horizontal:rep(width - knob_position), false, interactions),
			Element:new((" %d%%"):format(props.value))
		),
	}
end

--- @param props? { title?: string, value?: integer, config?: ascii-ui.Config }
function Slider(props)
	return function()
		props = props or {}
		props.value = props.value or 0
		props.config = props.config or {}
		props.title = props.title or ""
		return render(props)
	end
end

return Slider
