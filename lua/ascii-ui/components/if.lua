local createComponent = require("ascii-ui.components.functional-component")
local Bufferline = require("ascii-ui.buffer.bufferline")

local function empty()
	return { Bufferline:new() }
end

--- @alias ascii-ui.IfComponentProps { child: function, fallback: fun(), condition: fun(): boolean }

--- @param props ascii-ui.IfComponentProps
--- @return fun(): ascii-ui.BufferLine[]
local function If(props)
	if props.condition() then
		return props.child()
	end
	return empty
end

return createComponent("If", If, { avoid_memoize = true })
