local Segment = require("ascii-ui.buffer.segment")
local createComponent = require("ascii-ui.components.create-component")
local highlights = require("ascii-ui.highlights")
local interaction_type = require("ascii-ui.interaction_type")

--- @alias ascii-ui.ButtonComponent.Props { label: string, on_press?: fun() }

--- @param props ascii-ui.ButtonComponent.Props
local function Button(props)
	return {
		Segment:new({
			content = props.label,
			highlight = highlights.BUTTON,
			is_focusable = true,
			interactions = {
				[interaction_type.SELECT] = props.on_press,
			},
		}):wrap(),
	}
end

return createComponent("Button", Button, { label = "string", on_press = "function" })
