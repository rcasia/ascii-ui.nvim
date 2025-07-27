local BufferLine = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")

local useState = require("ascii-ui.fiber").useState
local i = require("ascii-ui.interaction_type")
local useConfig = require("ascii-ui.hooks.use_config")

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
local function Tree(props)
	local config = useConfig()
	local cc = config.characters
	-- combinations of characters
	local LEAF_PREFIX = cc.bottom_left .. cc.horizontal .. cc.whitespace
	local LEFT_TREE_PREFIX = cc.left_tree .. cc.horizontal .. cc.whitespace
	local RIGHT_TRIANGULE = cc.right_triangule .. cc.whitespace
	local DOWN_TRIANGULE = cc.down_triangule .. cc.whitespace

	if props.tree.expanded == nil then
		props.tree.expanded = true
	end

	local is_expanded, set_expanded = useState(props.tree.expanded)
	local toggle_expanded = function()
		set_expanded(not is_expanded)
	end
	props.level = props.level or 0
	props.has_siblings = props.has_siblings or false
	props.is_last = props.is_last or false
	local children_count = props.tree.children and #props.tree.children or 0
	local has_children_siblings = children_count > 1
	local is_head = props.level == 0

	-- if is leaf node
	local has_children = props.tree and props.tree.children and #props.tree.children > 0
	if not has_children then
		local prefix = ""
		if props.is_last then
			prefix = LEAF_PREFIX
		elseif props.level > 0 then
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
			return Tree({
				tree = child,
				level = props.level + 1,
				has_siblings = has_children_siblings,
				is_last = index == children_count,
			})
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
