local Component = require("ascii-ui.components.component")

local create_dummy_component = function()
	local DummyComponent = {
		name = "DummyComponent",
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

	return DummyComponent:new({ dummy_check = true })
end

return create_dummy_component
