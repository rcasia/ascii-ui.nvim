local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")
local interaction_type = require("ascii-ui.interaction_type")
local useReducer = require("ascii-ui.hooks.use_reducer")

local function compact(t)
	return vim.iter(t)
		:filter(function(item)
			return item ~= nil
		end)
		:totable()
end

--- @param props? { title?: string, value?: integer, config?: ascii-ui.Config }
---@return ascii-ui.BufferLine[]
local function render(props, config)
	local _props, dispatch = useReducer(function(state, action)
		if action == "move_right" then
			state.value = math.min(state.value + 10, 100)
		end

		if action == "move_left" then
			state.value = math.max(state.value - 10, 0)
		end

		return state
	end, props)

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

	return compact({
		props.title ~= "" and Element:new(props.title, false):wrap() or nil,
		Bufferline.new(
			Element:new({
				content = cc.horizontal:rep(knob_position),
				interactions = interactions,
			}),

			Element:new({ content = cc.thumb, is_focusable = true, interactions = interactions }),
			Element:new({ content = cc.horizontal:rep(width - knob_position), interactions = interactions }),
			Element:new({ content = (" %d%%"):format(props.value) })
		),
	})
end

--- @param props? { title?: string, value?: integer }
local function Slider(props)
	local config = config or require("ascii-ui.config")
	props = props or {}
	props.value = props.value or 0
	props.title = props.title or ""
	return render(props, config)
end

return createComponent("Slider", Slider, { title = "string", value = "number", config = "table" })
