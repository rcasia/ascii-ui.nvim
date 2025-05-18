local Bufferline = require("ascii-ui.buffer.bufferline")
local createComponent = require("ascii-ui.components.functional-component")

local function empty()
	return { Bufferline:new() }
end

--- @alias ascii-ui.IfComponentProps { child: function, fallback: function, condition: fun(): boolean }

--- @param props ascii-ui.IfComponentProps
--- @return fun(): ascii-ui.BufferLine[]
local function If(props)
	return function()
		local fallback = props.fallback or empty

		if props.condition() then
			return props.child()
		end

		return fallback()
	end
end

return createComponent("If", If, { avoid_memoize = true })
