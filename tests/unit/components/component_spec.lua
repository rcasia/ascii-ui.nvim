require("luassert")
local eq = assert.are.same

local Component = require("ascii-ui.components.component")

local function create_dummy_component()
	---@class DummyComponent : ascii-ui.Component
	---@field name string
	local DummyComponent = {
		name = "DummyComponent",
	}

	---@return DummyComponent
	function DummyComponent:new()
		Component:new()

		return Component:extend(self)
	end

	return DummyComponent:new()
end

describe("Component", function()
	it("should be extensible", function()
		local component = create_dummy_component()
		eq("DummyComponent", component.name)
		eq("BaseComponent", component.__name)
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
