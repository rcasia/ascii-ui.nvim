require("luassert")
local eq = assert.are.same

local Component = require("ascii-ui.components.component")

describe("Component", function()
	it("should subscribe to functions and run them on state changes", function()
		local interactions_count = 0
		local state = { a = 1, b = 2 }
		local component = Component:new(state)

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
