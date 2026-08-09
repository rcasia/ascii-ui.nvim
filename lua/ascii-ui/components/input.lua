local Segment = require("ascii-ui.buffer.segment")
local createComponent = require("ascii-ui.components.create-component")
local interaction_type = require("ascii-ui.interaction_type")
local useState = require("ascii-ui.hooks.use_state")

--- @alias ascii-ui.InputProps { value?: string, initial_value?: string, password?: boolean, placeholder?: string, on_change?: fun(value: string) }

--- @param props? ascii-ui.InputProps
return createComponent(
	"Input",
	function(props)
		props = props or {}

		-- Initialize state with initial value or empty string
		local initial = props.initial_value or props.value or ""
		local value, setValue = useState(initial)

		-- Guard: ensure value is always a string
		if type(value) ~= "string" then
			value = ""
		end

		-- Handle value updates from props
		if props.value ~= nil and props.value ~= value then
			setValue(props.value)
			value = props.value
		end

		-- Build display text
		local display_text = value
		if props.password and display_text ~= "" then
			display_text = string.rep("*", #display_text)
		elseif display_text == "" and props.placeholder then
			display_text = props.placeholder
		end

		return {
			Segment:new({
				content = display_text,
				is_focusable = true,
				interactions = {
					[interaction_type.INPUT] = function(new_value)
						-- Ensure new_value is a string
						if type(new_value) ~= "string" then
							new_value = ""
						end
						setValue(new_value)
						if props.on_change then
							props.on_change(new_value)
						end
					end,
				},
			}):wrap(),
		}
	end,
	{ value = "string", initial_value = "string", password = "boolean", placeholder = "string", on_change = "function" }
)
