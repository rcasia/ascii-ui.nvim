local BufferLine = require("ascii-ui.buffer.bufferline")
local FiberNode = require("ascii-ui.fibernode")
local Segment = require("ascii-ui.buffer.segment")
local createComponent = require("ascii-ui.components.create-component")

local i = require("ascii-ui.interaction_type")
local useConfig = require("ascii-ui.hooks.use_config")
local useState = require("ascii-ui.hooks.use_state")

--- @class ascii-ui.TreeComponentProps.TreeNode
--- @field text string
--- @field children? (ascii-ui.TreeComponentProps.TreeNode|ascii-ui.FiberNode)[]
--- @field expanded? boolean

--- @class ascii-ui.TreeComponentProps
--- @field tree ascii-ui.TreeComponentProps.TreeNode
--- @field level? integer
--- @field has_siblings? boolean
--- @field is_last? boolean

--- Check if a child is a TreeNode (has text field) or a component
--- @param child any
--- @return boolean
local function is_tree_node(child)
	return type(child) == "table" and type(child.text) == "string"
end

--- @param props ascii-ui.TreeComponentProps
local function Tree(props)
	local config = useConfig()
	local cc = config.characters
	-- combinations of characters
	local LEAF_PREFIX = cc.bottom_left .. cc.horizontal .. cc.whitespace
	local LEFT_TREE_PREFIX = cc.left_tree .. cc.horizontal .. cc.whitespace
	local RIGHT_TRIANGULE = cc.right_triangule .. cc.whitespace
	local DOWN_TRIANGULE = cc.horizontal .. cc.whitespace .. cc.down_triangule .. cc.whitespace

	if props.tree.expanded == nil then
		props.tree.expanded = true
	end

	local is_expanded, set_expanded = useState(props.tree.expanded)
	local toggle_expanded = function()
		set_expanded(not is_expanded)
	end
	local level = props.level or 0
	local has_siblings = props.has_siblings or false
	local is_last = props.is_last or false
	props.level = level
	props.has_siblings = has_siblings
	props.is_last = is_last
	local children_count = props.tree.children and #props.tree.children or 0
	local has_children_siblings = children_count > 1
	local is_head = level == 0

	-- if is leaf node
	local has_children = props.tree and props.tree.children and #props.tree.children > 0
	if not has_children then
		local prefix = ""
		if is_last then
			prefix = LEAF_PREFIX
		elseif level > 0 then
			prefix = LEFT_TREE_PREFIX
		end
		return {
			BufferLine.new(
				Segment:new({ content = prefix }),
				Segment:new({ content = props.tree.text, is_focusable = true })
			),
		}
	end

	if not is_expanded then
		-- if node is not expanded, render only the node text
		local prefix = props.is_last and LEAF_PREFIX or LEFT_TREE_PREFIX
		return {
			BufferLine.new(
				Segment:new({ content = prefix }),
				Segment:new({
					content = RIGHT_TRIANGULE,
				}),
				Segment:new({
					content = props.tree.text,
					is_focusable = true,
					interactions = {
						[i.SELECT] = toggle_expanded,
					},
				})
			),
		}
	end

	-- when has children
	local lines = vim.iter(props.tree.children)
		:enumerate()
		:map(function(index, child)
			local is_child_last = index == children_count
			local child_lines

			if is_tree_node(child) then
				-- Child is a TreeNode, recurse
				child_lines = Tree({
					tree = child,
					level = props.level + 1,
					has_siblings = has_children_siblings,
					is_last = is_child_last,
				})
			else
				-- Child is a component (FiberNode or BufferLine)
				-- Determine prefix based on position
				local prefix
				if is_child_last then
					prefix = LEAF_PREFIX
				else
					prefix = LEFT_TREE_PREFIX
				end

				-- Render the component and wrap with prefix
				if FiberNode.is_node(child) then
					-- It's a FiberNode, unwrap it to get BufferLines
					local unwrapped = child:unwrap_closure()
					child_lines = vim.iter(unwrapped)
						:enumerate()
						:map(function(idx, node)
							if idx == 1 then
								-- First line gets the prefix
								return BufferLine.new(Segment:new({ content = prefix })):append(node:get_line())
							else
								-- Subsequent lines get indentation
								local indent = cc.whitespace:rep(#prefix)
								return BufferLine.new(Segment:new({ content = indent })):append(node:get_line())
							end
						end)
						:totable()
				elseif BufferLine.is_bufferline(child) then
					-- It's already a BufferLine
					child_lines = { BufferLine.new(Segment:new({ content = prefix })):append(child) }
				else
					error("Tree child must be a TreeNode, FiberNode, or BufferLine")
				end
			end

			return child_lines
		end)
		:flatten()
		:map(function(child)
			return Segment:new({ content = props.has_siblings and not props.is_last and cc.vertical or cc.whitespace })
				:wrap()
				:append(child)
		end)
		:totable()

	return {

		BufferLine.new(
			not is_head and Segment:new({ content = cc.bottom_left .. cc.top_right }),
			not is_head and Segment:new({
				content = DOWN_TRIANGULE,
			}),
			Segment:new({
				content = props.tree.text,
				is_focusable = true,

				interactions = {
					[i.SELECT] = toggle_expanded,
				},
			})
		),
		unpack(lines),
	}
end

return createComponent("Tree", Tree, {
	tree = "table",
	level = "number",
	has_siblings = "boolean",
	is_last = "boolean",
})
