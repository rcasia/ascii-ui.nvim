pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Renderer = require("ascii-ui.renderer")
local Tree = require("ascii-ui.components.tree")

describe("Tree Component", function()
	local renderer = Renderer:new({})

	it("renders just top node", function()
		local tree = {
			text = "dummy_treenode",
		}
		local closure = Tree({ tree = tree })

		eq([[dummy_treenode]], renderer:render(closure):to_string())
	end)

	it("renders just top node and its children", function()
		--- @type ascii-ui.TreeComponentProps.TreeNode
		local tree = {
			text = "node-1",
			children = {
				{ text = "node-1-1" },
				{ text = "node-1-2" },
			},
		}
		local closure = Tree({ tree = tree })

		eq(
			vim.trim([[node-1
 ├─ node-1-1
 ╰─ node-1-2]]),
			renderer:render(closure):to_string()
		)
	end)

	it("renders level 3 children", function()
		--- @type ascii-ui.TreeComponentProps.TreeNode
		local tree = {
			text = "node-1",
			children = {
				{ text = "node-1-1", children = { { text = "node-1-1-1" } } },
				{ text = "node-1-2" },
			},
		}
		local closure = Tree({ tree = tree })

		eq(
			vim.trim([[node-1
 ╰╮  node-1-1
 │╰─ node-1-1-1
 ╰─ node-1-2]]),
			renderer:render(closure):to_string()
		)
	end)
end)
