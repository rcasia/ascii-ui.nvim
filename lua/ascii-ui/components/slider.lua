local Bufferline = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local createComponent = require("ascii-ui.components.create-component")
local interaction_type = require("ascii-ui.interaction_type")
local useConfig = require("ascii-ui.hooks.use_config")
local useEffect = require("ascii-ui.hooks.use_effect")
local useState = require("ascii-ui.hooks.use_state")

local MIN_VALUE = 0
local MAX_VALUE = 100
local STEP = 10

--- @param props? { title?: string, value?: integer, on_change?: fun(value: integer) }
local function Slider(props)
	local config = useConfig()
	props = props or {}
	props.value = props.value or MIN_VALUE
	props.title = props.title or ""

	local cc = config.characters
	local value, setValue = useState(props.value or MIN_VALUE)

	useEffect(function()
		if props.on_change then
			props.on_change(value)
		end
	end, { value })

	local decrease = function()
		setValue(function(v)
			return math.max(v - STEP, MIN_VALUE)
		end)
	end

	local increase = function()
		setValue(function(v)
			return math.min(v + STEP, MAX_VALUE)
		end)
	end

	local width = STEP
	local knob_position = math.floor(width * value / MAX_VALUE)

	return {
		props.title ~= "" and Segment:new(props.title):wrap(),
		Bufferline.new(
			Segment:new({
				content = cc.horizontal:rep(knob_position),
			}),
			Segment:new({
				content = cc.thumb,
				interactions = {
					[interaction_type.CURSOR_MOVE_RIGHT] = increase,
					[interaction_type.CURSOR_MOVE_LEFT] = decrease,
				},
			}),
			Segment:new({ content = cc.horizontal:rep(width - knob_position) }),
			Segment:new({ content = (" %d%%"):format(value) })
		),
	}
end

return createComponent(
	"Slider",
	Slider,
	{ title = "string", value = "number", config = "table", on_change = "function" }
)
