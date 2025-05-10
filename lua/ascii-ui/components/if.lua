local createComponent = require("ascii-ui.components.functional-component")
local Bufferline = require("ascii-ui.buffer.bufferline")

local function empty()
	return { Bufferline:new() }
end

--- @alias ascii-ui.IfComponentProps { child: function, fallback: function, condition: fun(): boolean }

--- @param props ascii-ui.IfComponentProps
--- @return fun(): ascii-ui.BufferLine[]
local function If(props)
	return function()
		if props.condition() then
			return props.child()
		end

		if not not props.fallback then
			print("hola desde fallback")
			return props.fallback()
		end
		return empty()
	end
end

return createComponent("If", If, { avoid_memoize = true })
