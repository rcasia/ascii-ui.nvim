local BufferLine = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")

local createComponent = require("ascii-ui.components.create-component")

---@return ascii-ui.BufferLine[]
local function DummyComponent()
	return function()
		return { BufferLine.new(Segment:new("dummy_render")) }
	end
end
return createComponent("DummyComponent", DummyComponent)
