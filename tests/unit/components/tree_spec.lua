pcall(require, "luacov")
local assert = require("luassert")

local eq = assert.are.same

local Renderer = require("ascii-ui.renderer")
local Tree = require("ascii-ui.components.tree")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")

describe("Tree Component", function()
	local renderer = Renderer:new({})

	it("renders just top node", function()
		local App = ui.createComponent("App", function()
			return Tree({ tree = { text = "dummy_treenode" } })
		end, {})
		local buffer = fiber.render(App)

		eq([[dummy_treenode]], buffer:to_string())
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
		local App = ui.createComponent("App", function()
			return Tree({ tree = tree })
		end, {})

		eq(
			vim.trim([[node-1
 ├─ node-1-1
 ╰─ node-1-2]]),
			renderer:render(App):to_string()
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
		local App = ui.createComponent("App", function()
			return Tree({ tree = tree })
		end, {})

		eq({
			--
			"node-1",
			" ╰╮─ ▾ node-1-1",
			" │╰─ node-1-1-1",
			" ╰─ node-1-2",
		}, renderer:render(App):to_lines())
	end)

	it("renders last level one node with space before its children", function()
		--- @type ascii-ui.TreeComponentProps.TreeNode
		local tree = {
			text = "node-1",
			children = {
				{ text = "node-1-1" },
				{ text = "node-1-2" },
				{ text = "node-1-3", children = { { text = "node-1-3-1", children = { { text = "node-1-3-1-1" } } } } },
			},
		}
		local App = ui.createComponent("App", function()
			return Tree({ tree = tree })
		end, {})

		eq({
			"node-1",
			" ├─ node-1-1",
			" ├─ node-1-2",
			" ╰╮─ ▾ node-1-3",
			"  ╰╮─ ▾ node-1-3-1",
			"   ╰─ node-1-3-1-1",
		}, renderer:render(App):to_lines())
	end)

	it("renders nodes that are not expanded", function()
		--- @type ascii-ui.TreeComponentProps.TreeNode
		local tree = {
			text = "node-1",
			children = {
				{ text = "node-1-1" },
				{ text = "node-1-2", expanded = false, children = { { text = "node-1-2-1" } } },
				{
					text = "node-1-3",
					expanded = false,
					children = { { text = "node-1-3-1", children = { { text = "node-1-3-1-1" } } } },
				},
			},
		}
		local App = ui.createComponent("App", function()
			return Tree({ tree = tree })
		end, {})
		local result = renderer:render(App):to_string()

		eq(
			[[node-1
 ├─ node-1-1
 ├─ ▸ node-1-2
 ╰─ ▸ node-1-3]],
			result
		)
	end)
end)
