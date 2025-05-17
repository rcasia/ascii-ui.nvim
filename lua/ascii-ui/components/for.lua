local createComponent = require("ascii-ui.components.functional-component")

--- @class ascii-ui.ForComponentProps
--- @field props table[]
--- @field items any[] | fun(): any[]
--- @field component ascii-ui.FunctionalComponent
--- @field transform fun(item: any): table

--- @param props ascii-ui.ForComponentProps
--- @return fun(): ascii-ui.BufferLine[]
local function For(props)
	props = props or {}
	local inner_props = props.props or {}

	return function()
		local items = type(props.items) == "function" and props.items() or props.items
		if items then
			inner_props = vim.iter(items)
				:map(function(item)
					if props.transform then
						return props.transform(item)
					end
					return item
				end)
				:totable()
		end

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
