local Element = require("ascii-ui.buffer.element")
local ui = require("ascii-ui")

--- @alias ascii-ui.InputProps { value?: string }

--- @param props? ascii-ui.InputProps
--- @return fun(): ascii-ui.BufferLine[]
return ui.createComponent("Input", function(props)
	props = props or {}
	props.value = props.value or ""

	return {
		Element:new({
			content = props.value,
			is_focusable = true,
			interactions = {
				ON_INPUT = function() end,
			},
		}):wrap(),
	}
end, { value = "string" })
