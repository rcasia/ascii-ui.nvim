local Segment = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")
local useState = require("ascii-ui.hooks.use_state")

--- @class ascii-ui.TreeComponentProps.TreeNode
--- @field text string
--- @field children? ascii-ui.TreeComponentProps.TreeNode[]
--- @field expanded? boolean

--- @class ascii-ui.TreeComponentProps
--- @field tree ascii-ui.TreeComponentProps.TreeNode
--- @field level? integer
--- @field has_siblings? boolean
--- @field is_last? boolean

--- @param props ascii-ui.TreeComponentProps
--- @return fun(): ascii-ui.BufferLine[]
local function Tree(props)
	if props.tree.expanded == nil then
		props.tree.expanded = true
	end
	local is_expanded, _ = useState(props.tree.expanded)

	return function()
		props.level = props.level or 0
		props.has_siblings = props.has_siblings or false
		props.is_last = props.is_last or false
		local children_count = props.tree.children and #props.tree.children or 0
		local has_children_siblings = children_count > 1

		-- if is leaf node
		local has_children = props.tree and props.tree.children and #props.tree.children > 0
		if not has_children then
			local prefix = ""
			if props.is_last then
				prefix = "╰─ "
			elseif props.level > 0 then
				prefix = "├─ "
			end
			return { Segment:new({ content = prefix .. props.tree.text }):wrap() }
		end

		if not is_expanded() then
			-- if node is not expanded, render only the node text
			local prefix = props.is_last and "╰─ ▸ " or "├─ ▸ "
			return { Segment:new({ content = prefix .. props.tree.text }):wrap() }
		end

		-- when has children
		local lines = vim.iter(props.tree.children)
			:enumerate()
			:map(function(index, child)
				return Tree({
					tree = child,
					level = props.level + 1,
					has_siblings = has_children_siblings,
					is_last = index == children_count,
				})()
			end)
			:flatten()
			:map(function(child)
				return Segment:new({ content = props.has_siblings and not props.is_last and "│" or " " })
					:wrap()
					:append(child)
			end)
			:totable()

		local prefix = props.level > 0 and "╰╮▾ " or ""

		return {
			Segment:new({ content = prefix .. props.tree.text }):wrap(),
			unpack(lines),
		}
	end
end

return createComponent("Tree", Tree, { tree = "table" })
