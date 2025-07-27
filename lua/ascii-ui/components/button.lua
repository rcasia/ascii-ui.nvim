local Element = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")
local highlights = require("ascii-ui.highlights")
local interaction_type = require("ascii-ui.interaction_type")

--- @alias ascii-ui.ButtonComponent.Props { label: string, on_press?: fun() }

--- @type ascii-ui.FunctionalComponent<ascii-ui.ButtonComponent.Props>
--- @return ComponentClosure
local function Button(props)
	return function()
		return {
			Element:new({
				content = props.label,
				highlight = highlights.BUTTON,
				is_focusable = true,
				interactions = {
					[interaction_type.SELECT] = props.on_press,
				},
			}):wrap(),
		}
	end
end

return createComponent("Button", Button, { label = "string", on_press = "function" })
