local Segment = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")
local logger = require("ascii-ui.logger")

--- @class ascii-ui.TreeComponentProps.TreeNode
--- @field text string
--- @field children? ascii-ui.TreeComponentProps.TreeNode[]

--- @class ascii-ui.TreeComponentProps
--- @field tree ascii-ui.TreeComponentProps.TreeNode
--- @field level? integer
--- @field has_siblings? boolean
---
--- @param props ascii-ui.TreeComponentProps
--- @return fun(): ascii-ui.BufferLine[]
local function Tree(props)
	return function()
		props.level = props.level or 0
		props.has_siblings = props.has_siblings or false

		local has_children = props.tree and props.tree.children and #props.tree.children > 0
		if not has_children then
			-- logger.debug("Rendering leaf tree node: %s", vim.inspect(props.tree))
			local prefix = props.level == 0 and "" or "├─ "
			return { Segment:new({ content = prefix .. props.tree.text }):wrap() }
		end

		-- logger.debug("Rendering tree node: %s", vim.inspect(props.tree))

		local has_children_siblings = #props.tree.children > 1
		local lines = vim.iter(props.tree.children)
			:map(function(child)
				return Tree({ tree = child, level = props.level + 1, has_siblings = has_children_siblings })()
			end)
			:flatten()
			:map(function(child)
				return Segment:new({ content = props.has_siblings and "│" or " " }):wrap():append(child)
			end)
			:totable()
		logger.debug("Rendering tree node with children: %s", vim.inspect(lines))

		-- local child = Tree({ tree = props.tree.children[1] })()
		-- local child2 = Tree({ tree = props.tree.children[2] })()
		--
		local prefix = props.level > 0 and "╰╮  " or ""

		-- if props.has_siblings then
		-- 	prefix = "│"
		-- end

		return {
			Segment:new({ content = prefix .. props.tree.text }):wrap(),
			unpack(lines),
			-- Segment:new({ content = "╰╮  " }):wrap():append(child[1]),
			-- Segment:new({ content = " ├─ " }):wrap():append(child2[1]),
		}
	end
end

return createComponent("Tree", Tree, { tree = "table" })
