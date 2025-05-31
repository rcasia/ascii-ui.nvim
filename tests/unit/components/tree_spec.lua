pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Renderer = require("ascii-ui.renderer")
local Tree = require("ascii-ui.components.tree")

describe("Tree Component", function()
	local renderer = Renderer:new({})

	it("renders just top node", function()
		local closure = Tree({})

		eq([[dummy_treenode]], renderer:render(closure):to_string())
	end)
end)
