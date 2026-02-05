pcall(require, "luacov")

local ui = require("ascii-ui")
local eq = assert.are.same

describe("ui.map", function()
	local MyComponent = ui.createComponent("MyComponent", function(props)
		return {
			ui.blocks.Segment({ content = "Item: " .. props.item }):wrap(),
		}
	end, { item = "string" })

	it("maps items into components", function()
		local items = { "apple", "banana", "cherry" }

		eq(
			{
				MyComponent({ item = "apple" }),
				MyComponent({ item = "banana" }),
				MyComponent({ item = "cherry" }),
			},
			ui.map(items, function(item)
				return MyComponent({ item = item })
			end)
		)
	end)
end)
