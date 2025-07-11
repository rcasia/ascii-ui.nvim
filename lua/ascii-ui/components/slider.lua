local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")
local interaction_type = require("ascii-ui.interaction_type")
local useState = require("ascii-ui.hooks.use_state")

local function compact(t)
	return vim.iter(t)
		:filter(function(item)
			return item ~= nil
		end)
		:totable()
end

--- @param props? { title?: string, value?: integer }
local function Slider(props)
	local config = require("ascii-ui.config")
	props = props or {}
	props.value = props.value or 0
	props.title = props.title or ""

	return function()
		local cc = config.characters
		local value, setValue = useState(props.value or 0)

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

		return compact({
			props.title ~= "" and Element:new(props.title, false):wrap() or nil,
			Bufferline.new(
				Element:new({
					content = cc.horizontal:rep(knob_position),
					interactions = interactions,
				}),

				Element:new({ content = cc.thumb, is_focusable = true, interactions = interactions }),
				Element:new({ content = cc.horizontal:rep(width - knob_position), interactions = interactions }),
				Element:new({ content = (" %d%%"):format(value) })
			),
		})
	end
end

return createComponent("Slider", Slider, { title = "string", value = "number", config = "table" })
