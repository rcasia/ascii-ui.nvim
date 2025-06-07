local BufferLine = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")

local createComponent = require("ascii-ui.components.functional-component")

---@return ascii-ui.BufferLine[]
local function DummyComponent()
	return { BufferLine.new(Element:new("dummy_render")) }
end
return createComponent("DummyComponent", DummyComponent)
