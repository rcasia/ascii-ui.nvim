local Bufferline = require("ascii-ui.buffer.bufferline")
local createComponent = require("ascii-ui.components.create-component")

local function empty()
	return { Bufferline.new() }
end

--- @alias ascii-ui.IfComponentProps { child: ascii-ui.FiberNode, fallback: ascii-ui.FiberNode, condition: fun(): boolean }

--- @param props ascii-ui.IfComponentProps
local function If(props)
	local fallback = props.fallback or empty

	if props.condition() then
		return props.child
	end

	return fallback
end

return createComponent("If", If, {
	condition = "function",
	child = "table",
	fallback = "table",
})
