local createComponent = require("ascii-ui.components.functional-component")
local Bufferline = require("ascii-ui.buffer.bufferline")

--- @alias ascii-ui.ForComponentProps { props: table<string, any>[], items: any, transform: fun(item: any), component: ascii-ui.Component }

--- @param props ascii-ui.ForComponentProps
--- @return fun(): ascii-ui.BufferLine[]
local function For(props)
	props = props or {}
	local inner_props = props.props or {}

	if props.items then
		inner_props = vim.iter(props.items)
			:map(function(item)
				if props.transform then
					return props.transform(item)
				end
				return item
			end)
			:totable()
	end

	return function()
		return vim.iter(inner_props)
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
