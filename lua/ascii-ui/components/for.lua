local createComponent = require("ascii-ui.components.functional-component")
local Bufferline = require("ascii-ui.buffer.bufferline")

--- @alias ascii-ui.ForComponentProps { child: function, fallback: function, condition: fun(): boolean }

--- @param props ascii-ui.IfComponentProps
--- @return fun(): ascii-ui.BufferLine[]
local function For(props)
	return function()
		return Bufferline:new()
	end
end

return createComponent("For", For)
