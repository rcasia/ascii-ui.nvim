pcall(require, "luacov")
---@module "luassert"
local eq = assert.are.same

local Buffer = require("ascii-ui.buffer")
local Hightlights = require("ascii-ui.highlights")
local Select = require("ascii-ui.components.select")

describe("SelectComponent", function()
	it("renders elements", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Select({ options = option_names })

		local render_1 = options()
		eq({
			"[x] apple",
			"[ ] banana",
			"[ ] mango",
		}, Buffer.new(unpack(render_1)):to_lines())
	end)

	it("renders selected element with color", function()
		local option_names = { "apple", "banana", "mango" }
		local options = Select({ options = option_names })

		local selected_element = assert(Buffer.new(unpack(options())):find_element_by_position({ line = 1, col = 1 })) -- the first element is selected

		eq(Hightlights.SELECTION, selected_element.highlight)
		eq(nil, Buffer.new(unpack(options())):find_element_by_position({ line = 2, col = 1 }).highlight)
		eq(nil, Buffer.new(unpack(options())):find_element_by_position({ line = 3, col = 1 }).highlight)

		local second_selected_element =
			assert(Buffer.new(unpack(options())):find_element_by_position({ line = 2, col = 1 }))

		second_selected_element.interactions["SELECT"]()

		-- Re-renderiza para reflejar el nuevo estado
		local new_render = Buffer.new(unpack(options()))

		local newly_selected = assert(new_render:find_element_by_position({ line = 2, col = 1 }))
		eq(Hightlights.SELECTION, newly_selected.highlight)
	end)

	it("uses the user defined function on select", function()
		local option_names = { "apple", "banana", "mango" }
		local user_recieved_selected_option
		local user_defined_on_select_fun = function(selected_element)
			print("selected  " .. selected_element)
			user_recieved_selected_option = selected_element
		end
		local select = Select({ options = option_names, on_select = user_defined_on_select_fun })

		local selected_element = assert(Buffer.new(unpack(select())):find_element_by_position({ line = 1, col = 1 })) -- the first element is selected

		selected_element.interactions["SELECT"]()
		eq("apple", user_recieved_selected_option)
	end)

	it("can have a title", function()
		local option_names = { "apple", "banana", "mango" }
		local title = "Select a fruit:"
		local options = Select({ options = option_names, title = title })

		local render = options()
		eq({
			"Select a fruit:",
			"[x] apple",
			"[ ] banana",
			"[ ] mango",
		}, Buffer.new(unpack(render)):to_lines())
	end)
end)
