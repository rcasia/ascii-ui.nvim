local BufferLine = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")

local createComponent = require("ascii-ui.components.create-component")

---@return ascii-ui.BufferLine[]
local function DummyComponent()
	return function()
		return { BufferLine.new(Element:new("dummy_render")) }
	end
end
return createComponent("DummyComponent", DummyComponent)
