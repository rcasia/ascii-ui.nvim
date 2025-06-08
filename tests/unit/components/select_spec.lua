pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Hightlights = require("ascii-ui.highlights")
local Select = require("ascii-ui.components.select")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")

describe("SelectComponent", function()
	it("renders elements", function()
		local option_names = { "apple", "banana", "mango" }
		local App = ui.createComponent("Test", function()
			return Select({ options = option_names })
		end)

		eq({
			"[x] apple",
			"[ ] banana",
			"[ ] mango",
		}, fiber.render(App):to_lines())
	end)

	it("renders selected element with color", function()
		local option_names = { "apple", "banana", "mango" }

		local App = ui.createComponent("Test", function()
			return Select({ options = option_names })
		end)
		local buffer, root = fiber.render(App)
		local selected_element = assert(buffer:find_element_by_position({ line = 1, col = 1 })) -- the first element is selected

		eq(Hightlights.SELECTION, selected_element.highlight)
		eq(nil, buffer:find_element_by_position({ line = 2, col = 1 }).highlight)
		eq(nil, buffer:find_element_by_position({ line = 3, col = 1 }).highlight)

		local second_selected_element = assert(buffer:find_element_by_position({ line = 2, col = 1 }))

		second_selected_element.interactions["SELECT"]()

		-- Re-renderiza para reflejar el nuevo estado
		local new_buffer = fiber.rerender(root)

		local newly_selected = assert(new_buffer:find_element_by_position({ line = 2, col = 1 }))
		eq(Hightlights.SELECTION, newly_selected.highlight)
	end)

	it("uses the user defined function on select", function()
		local option_names = { "apple", "banana", "mango" }
		local user_received_selected_option
		local user_defined_on_select_fun = function(selected_element)
			print("selected  " .. selected_element)
			user_received_selected_option = selected_element
		end

		local App = ui.createComponent("Test", function()
			return Select({ options = option_names, on_select = user_defined_on_select_fun })
		end)
		local buffer = fiber.render(App)

		local selected_element = assert(buffer:find_element_by_position({ line = 1, col = 1 })) -- the first element is selected

		selected_element.interactions["SELECT"]()
		eq("apple", user_received_selected_option)
	end)

	it("can have a title", function()
		local option_names = { "apple", "banana", "mango" }
		local title = "Select a fruit:"

		local App = ui.createComponent("Test", function()
			return Select({ options = option_names, title = title })
		end)

		local buffer = fiber.render(App)
		eq({
			"Select a fruit:",
			"[x] apple",
			"[ ] banana",
			"[ ] mango",
		}, buffer:to_lines())
	end)
end)
