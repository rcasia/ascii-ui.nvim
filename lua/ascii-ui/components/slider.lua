local Bufferline = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local createComponent = require("ascii-ui.components.create-component")
local interaction_type = require("ascii-ui.interaction_type")
local useConfig = require("ascii-ui.hooks.use_config")
local useEffect = require("ascii-ui.hooks.use_effect")
local useState = require("ascii-ui.hooks.use_state")

--- @param props? { title?: string, value?: integer, on_change?: fun(value: integer) }
local function Slider(props)
	local config = useConfig()
	props = props or {}
	props.value = props.value or 0
	props.title = props.title or ""

	local cc = config.characters
	local value, setValue = useState(props.value or 0)

	useEffect(function()
		if props.on_change then
			props.on_change(value)
		end
	end, { value })

	local interactions = {
		[interaction_type.CURSOR_MOVE_RIGHT] = function()
			setValue(function(v)
				return math.min(v + 10, 100)
			end)
		end,
		[interaction_type.CURSOR_MOVE_LEFT] = function()
			setValue(function(v)
				return math.max(v - 10, 0)
			end)
		end,
	}

	local width = 10
	local knob_position = math.floor(width * value / 100)

	return {
		props.title ~= "" and Segment:new(props.title):wrap(),
		Bufferline.new(
			Segment:new({
				content = cc.horizontal:rep(knob_position),
			}),
			Segment:new({ content = cc.thumb, interactions = interactions }),
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
