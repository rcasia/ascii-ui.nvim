local Segment = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")

--- @class ascii-ui.TreeComponentProps.TreeNode
--- @field text string
--- @field children? ascii-ui.TreeComponentProps.TreeNode[]

--- @alias ascii-ui.TreeComponentProps { tree: ascii-ui.TreeComponentProps.TreeNode }
--- @param props ascii-ui.TreeComponentProps
--- @return fun(): ascii-ui.BufferLine[]
local function Tree(props)
	return function()
		local has_children = props.tree and props.tree.children and #props.tree.children > 0

		if not has_children then
			return { Segment:new({ content = props.tree.text }):wrap() }
		end

		local child = Tree({ tree = props.tree.children[1] })()
		local child2 = Tree({ tree = props.tree.children[2] })()

		return {
			Segment:new({ content = props.tree.text }):wrap(),
			Segment:new({ content = "╰╮  " }):wrap():append(child[1]),
			Segment:new({ content = " ├─ " }):wrap():append(child2[1]),
		}
	end
end

return createComponent("Tree", Tree, { tree = "table" })
