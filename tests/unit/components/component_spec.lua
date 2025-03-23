pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Checkbox = require("ascii-ui.components.checkbox")
local create_dummy_component = require("tests.util.dummy_component")

describe("Component", function()
	it("should be extensible", function()
		local component = create_dummy_component()
		eq("DummyComponent", component.__name)
		assert(component:is_dummy_check())
		component:toggle_dummy_check()
		assert.is_false(component:is_dummy_check())
	end)

	it("should subscribe to functions and run them on state changes", function()
		local interactions_count = 0

		local component = create_dummy_component()

		component:subscribe(function()
			interactions_count = interactions_count + 1
		end)

		eq(true, component.dummy_check)
		eq(0, interactions_count)

		component.unchecked_field = 1
		eq(1, interactions_count)

		component:toggle_dummy_check()
		eq(2, interactions_count)

		component:toggle_dummy_check()
		eq(3, interactions_count)
	end)

	it("subscribes to functions and run them on state changes with Checkbox component", function()
		local interactions_count = 0

		local component = Checkbox:new()

		component:subscribe(function()
			interactions_count = interactions_count + 1
		end)

		eq(false, component:is_checked())
		eq(0, interactions_count)

		component.unchecked_field = 1
		eq(1, interactions_count)

		component:toggle()
		eq(true, component:is_checked())
		eq(2, interactions_count)
	end)

	it("unsubscribes", function()
		local interactions_count = 0

		local component = Checkbox:new()

		component:subscribe(function()
			interactions_count = interactions_count + 1
		end)

		component:clear_subscriptions()

		component.unchecked_field = 1
		component:toggle()
		eq(0, interactions_count)
	end)

	it("removes the subscriptions on destroy", function()
		local interactions_count = 0

		local component = Checkbox:new()

		component:subscribe(function()
			interactions_count = interactions_count + 1
		end)

		component:destroy()

		component.unchecked_field = 1
		component:toggle()
		eq(0, interactions_count)
	end)
end)
