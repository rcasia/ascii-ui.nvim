pcall(require, "luacov")
---@module "luassert"
local eq = assert.are.same

local Select = require("ascii-ui.components.select")
local Buffer = require("ascii-ui.buffer")
local Hightlights = require("ascii-ui.highlights")

describe("SelectComponent", function()
	it("cycles options", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Select:new({ options = option_names })

		eq("banana", options:select_next())
		eq("mango", options:select_next())
		eq("apple", options:select_next())
	end)

	it("selects by 1-based index", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Select:new({ options = option_names })

		eq("apple", options:select_index(1))
		eq("banana", options:select_index(2))
		eq("mango", options:select_index(3))
	end)

	it("renders elements", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Select:new({ options = option_names })

		local render_1 = options:render()
		eq({
			"[x] apple",
			"[ ] banana",
			"[ ] mango",
		}, Buffer:new(unpack(render_1)):to_lines())

		options:select_index(3)
		local render_2 = options:render()
		eq({
			"[ ] apple",
			"[ ] banana",
			"[x] mango",
		}, Buffer:new(unpack(render_2)):to_lines())
	end)

	it("renders selected element with color", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Select:new({ options = option_names })

		local selected_element =
			assert(Buffer:new(unpack(options:render())):find_element_by_position({ line = 1, col = 1 })) -- the first element is selected

		eq(Hightlights.SELECTION, selected_element.highlight)
		eq(nil, Buffer:new(unpack(options:render())):find_element_by_position({ line = 2, col = 1 }).highlight)
		eq(nil, Buffer:new(unpack(options:render())):find_element_by_position({ line = 3, col = 1 }).highlight)
	end)

	it("can have a title", function()
		local option_names = { "apple", "banana", "mango" }
		local title = "Select a fruit:"
		local options = Select:new({ options = option_names, title = title })

		local render = options:render()
		eq({
			"Select a fruit:",
			"[x] apple",
			"[ ] banana",
			"[ ] mango",
		}, Buffer:new(unpack(render)):to_lines())
	end)

	it("reacts to user interaction", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Select:new({ options = option_names })
		local render = options:render()

		local second_element = render[2].elements[1]
		second_element.interactions.on_select()
		eq("banana", options:selected())
	end)

	it("runs user function on select", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Select:new({ options = option_names })
		local expected_option_index = 3
		local expected_option = "mango"

		local actual_option
		options:on_select(function(selected_option)
			actual_option = selected_option
		end)

		options:select_index(expected_option_index)

		eq(expected_option, actual_option)
	end)

	it("runs user function on select only when selected option changed", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Select:new({ options = option_names })
		local invocations = 0
		local expected_invocations = 0

		options:on_select(function(_)
			invocations = invocations + 1
		end)

		options.title = "changed title" -- this triggers should not trigger on_select, but it does trigger on_change

		eq(expected_invocations, invocations)
	end)

	it("accepts on_select function on creation", function()
		local option_names = { "apple", "banana", "mango" }
		local invocations = 0
		local expected_invocations = 1
		local options = Select:new({
			options = option_names,
			on_select = function(_)
				invocations = invocations + 1
			end,
		})

		options:select_index(3)

		eq(expected_invocations, invocations)
	end)
end)
