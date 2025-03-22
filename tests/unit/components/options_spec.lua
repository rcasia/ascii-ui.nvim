---@module "luassert"
local eq = assert.are.same

local Options = require("ascii-ui.components.options")
local Buffer = require("ascii-ui.buffer.buffer")

describe("Options", function()
	it("cycles options", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Options:new({ options = option_names })

		eq("banana", options:select_next())
		eq("mango", options:select_next())
		eq("apple", options:select_next())
	end)

	it("selects by 1-based index", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Options:new({ options = option_names })

		eq("apple", options:select_index(1))
		eq("banana", options:select_index(2))
		eq("mango", options:select_index(3))
	end)

	it("renders elements", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Options:new({ options = option_names })

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
		local options = Options:new({ options = option_names })

		local selected_element =
			assert(Buffer:new(unpack(options:render())):find_element_by_position({ line = 1, col = 1 })) -- the first element is selected

		eq(selected_element.highlight, "AsciiUISelected")
	end)

	it("can have a title", function()
		local option_names = { "apple", "banana", "mango" }
		local title = "Select a fruit:"
		local options = Options:new({ options = option_names, title = title })

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
		local options = Options:new({ options = option_names })
		local render = options:render()

		local second_element = render[2].elements[1]
		second_element.interactions.on_select()
		eq("banana", options:selected())
	end)
end)
