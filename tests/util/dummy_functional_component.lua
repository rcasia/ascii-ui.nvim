local BufferLine = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local useState = require("ascii-ui.hooks.use_state")

local createComponent = require("ascii-ui.components.functional-component").createComponent

---@return fun(): ascii-ui.BufferLine[]
local function DummyComponent()
	local counter, setCounter = useState(0)

	return function()
		setCounter(counter() + 1)
		return { BufferLine:new(Element:new("dummy_render " .. tostring(counter()))) }
	end
end
return createComponent("DummyComponent", DummyComponent)
