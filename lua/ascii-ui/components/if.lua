local Element = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")

--- @param props { condition: fun(): boolean, child: fun(), fallback: fun()}
--- @return fun(): ascii-ui.BufferLine[]
local function If(props)
	return props.child()
end

return createComponent("If", If)
