local Segment = require("ascii-ui.buffer.segment")
local createComponent = require("ascii-ui.components.create-component")
local interaction_type = require("ascii-ui.interaction_type")
local useEffect = require("ascii-ui.hooks.use_effect")
local useState = require("ascii-ui.hooks.use_state")

--- @class ascii-ui.InputProps
--- @field value? string Controlled value
--- @field initial_value? string Initial value (uncontrolled)
--- @field placeholder? string Shown when empty + unfocused
--- @field on_change? fun(value: string) Fires on every text change
--- @field on_submit? fun(value: string) Fires on <CR> in insert mode
--- @field on_blur? fun(value: string) Fires on exit insert mode
--- @field password? boolean Mask display with *

--- @param props? ascii-ui.InputProps
return createComponent("Input", function(props)
	props = props or {}

	-- Internal state: use initial_value or value or empty string
	local initial = props.initial_value or props.value or ""
	local value, setValue = useState(initial)

	-- Sync controlled value from parent
	useEffect(function()
		if props.value ~= nil and props.value ~= value then
			setValue(props.value)
		end
	end, { props.value })

	-- Determine display text
	local display_text = value
	if props.password and value ~= "" then
		display_text = string.rep("*", #value)
	elseif value == "" and props.placeholder then
		display_text = props.placeholder
	end

	-- Create segment with input callbacks
	local segment = Segment:new({
		content = display_text,
		is_focusable = true,
		interactions = {
			[interaction_type.INPUT] = function() end, -- marker for inputable
		},
		_input_callbacks = {
			state_setter = setValue,
			on_change = props.on_change,
			on_submit = props.on_submit,
			on_blur = props.on_blur,
		},
	})

	return { segment:wrap() }
end, {
	value = "string",
	initial_value = "string",
	placeholder = "string",
	on_change = "function",
	on_submit = "function",
	on_blur = "function",
	password = "boolean",
})
