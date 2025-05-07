local Component = require("ascii-ui.components.component")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local highlights = require("ascii-ui.highlights")
local interaction_type = require("ascii-ui.interaction_type")

--- @alias ascii-ui.ButtonComponent.Props { label: string, on_press?: fun() }

--- @type ascii-ui.FunctionalComponent<ascii-ui.ButtonComponent.Props>
--- @return ascii-ui.Renderable
function Button(props)
	return function()
		local label = type(props.label) == "function" and props.label() or props.label
		return {
			Element:new({
				content = label,
				highlight = highlights.BUTTON,
				is_focusable = true,
				interactions = {
					[interaction_type.SELECT] = props.on_press,
				},
			}):wrap(),
		}
	end
end

return Button
