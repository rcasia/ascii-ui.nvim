local BufferLine = require("ascii-ui.buffer.bufferline")
local Component = require("ascii-ui.components.component")
local Element = require("ascii-ui.buffer.element")

local create_dummy_component = function()
	---@class DummyComponent : ascii-ui.Component
	local DummyComponent = {
		__name = "DummyComponent",
	}
	function DummyComponent:new(props)
		return Component:extend(self, props)
	end

	function DummyComponent:is_dummy_check()
		return self.dummy_check
	end

	function DummyComponent:toggle_dummy_check()
		self.dummy_check = not self.dummy_check
	end

	function DummyComponent.render()
		return { BufferLine:new(Element:new("dummy_render")) }
	end

	---@return fun(): ascii-ui.BufferLine[]
	function DummyComponent.fun()
		return function()
			return { BufferLine:new(Element:new("dummy_render")) }
		end
	end

	return DummyComponent:new({ dummy_check = true })
end

return create_dummy_component
