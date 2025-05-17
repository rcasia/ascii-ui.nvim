local createComponent = require("ascii-ui.components.functional-component")
local Bufferline = require("ascii-ui.buffer.bufferline")

--- @alias ascii-ui.ForComponentProps { props: table<string, any>[], component: ascii-ui.Component }

--- @param props ascii-ui.ForComponentProps
--- @return fun(): ascii-ui.BufferLine[]
local function For(props)
	props = props or {}

	return function()
		return vim.iter(props.props)
			:map(function(_props)
				return props.component(_props)
			end)
			:map(function(closure)
				return closure()
			end)
			:flatten()
			:totable()
	end
end

return createComponent("For", For)
