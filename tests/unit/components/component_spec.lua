require("luassert")
local eq = assert.are.same

local Component = require("ascii-ui.components.component")

local create_dummy_component = function()
	local DummyComponent = {
		name = "DummyComponent",
	}
	function DummyComponent:new()
		return Component:extend(self)
	end

	function DummyComponent:is_true()
		return true
	end

	return DummyComponent:new()
end

describe("Component", function()
	it("should be extensible", function()
		local component = create_dummy_component()
		eq("DummyComponent", component.name)
		eq("BaseComponent", component.__name)
		assert(component:is_true())
	end)

	it("should subscribe to functions and run them on state changes", function()
		local interactions_count = 0

		local component = create_dummy_component()

		component:subscribe(function()
			interactions_count = interactions_count + 1
		end)

		eq(0, interactions_count)

		component.a = 0
		eq(1, interactions_count)

		component.b = 0
		eq(2, interactions_count)
	end)
end)
