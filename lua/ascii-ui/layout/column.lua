local FiberNode = require("ascii-ui.fibernode")

--- @class ascii-ui.Column.Props
--- @field children? ascii-ui.FiberNode[]
--- @field gap? integer

--- Column layout component - arranges children vertically.
---
--- Can be called in two ways:
--- 1. With props table: `Column({ children = {...}, gap = 1 })`
--- 2. With varargs: `Column(child1, child2, child3)`
---
--- @param props_or_child1 ascii-ui.Column.Props | ascii-ui.FiberNode
--- @param ... ascii-ui.FiberNode
--- @return ascii-ui.FiberNode[]
local function Column(props_or_child1, ...)
	local props
	local rest = { ... }

	-- Detect if called with props table or varargs
	-- A props table has 'children' or 'gap' keys and is NOT a FiberNode
	local is_props_table = type(props_or_child1) == "table"
		and not FiberNode.is_node(props_or_child1)
		and (props_or_child1.children or props_or_child1.gap)

	if is_props_table then
		-- Called with props table
		props = props_or_child1
	else
		-- Called with varargs
		local children = { props_or_child1 }
		for _, child in ipairs(rest) do
			children[#children + 1] = child
		end
		props = { children = children }
	end

	-- Create a layout FiberNode with a closure that returns children
	local children = props.children or {}
	local node = FiberNode.new({
		type = "Column",
		props = props,
		layout = { direction = "column" },
		closure = function()
			return children
		end,
	})

	-- Return as array for reconciler
	return { node }
end

return Column
