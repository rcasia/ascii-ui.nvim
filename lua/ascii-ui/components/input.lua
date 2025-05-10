local ui = require("ascii-ui")
local Element = require("ascii-ui.buffer.element")

--- @alias ascii-ui.InputProps { value?: string }

--- @param props? ascii-ui.InputProps
--- @return fun(): ascii-ui.BufferLine[]
return ui.createComponent("Input", function(props)
	props = props or {}
	props.value = props.value or ""

	return function()
		return { Element:new({ content = props.value }):wrap() }
	end
end)
