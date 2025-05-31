local Segment = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")

--- @return fun(): ascii-ui.BufferLine[]
local function Tree()
	return function()
		return { Segment:new({ content = "dummy_treenode" }):wrap() }
	end
end

return createComponent("Tree", Tree, {})
