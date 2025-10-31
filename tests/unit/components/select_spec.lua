pcall(require, "luacov")
---@module "luassert"

local eq = require("tests.util.eq")

local Hightlights = require("ascii-ui.highlights")
local Select = require("ascii-ui.components.select")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")

describe("SelectComponent", function()
	it("renders segments", function()
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

	it("renders selected segment with color", function()
		local option_names = { "apple", "banana", "mango" }

		local App = ui.createComponent("Test", function()
			return Select({ options = option_names })
		end)
		local buffer, root = fiber.render(App)
		local selected_segment = assert(buffer:find_segment_by_position({ line = 1, col = 1 })) -- the first segment is selected

		eq(Hightlights.SELECTION, selected_segment.highlight)
		eq(nil, buffer:find_segment_by_position({ line = 2, col = 1 }).highlight)
		eq(nil, buffer:find_segment_by_position({ line = 3, col = 1 }).highlight)

		local second_selected_segment = assert(buffer:find_segment_by_position({ line = 2, col = 1 }))

		second_selected_segment.interactions["SELECT"]()

		-- Re-renderiza para reflejar el nuevo estado
		local new_buffer = fiber.rerender(root)

		local newly_selected = assert(new_buffer:find_segment_by_position({ line = 2, col = 1 }))
		eq(Hightlights.SELECTION, newly_selected.highlight)
	end)

	it("uses the user defined function on select", function()
		local option_names = { "apple", "banana", "mango" }
		local user_received_selected_option
		local user_defined_on_select_fun = function(selected_segment)
			print("selected  " .. selected_segment)
			user_received_selected_option = selected_segment
		end

		local App = ui.createComponent("Test", function()
			return Select({ options = option_names, on_select = user_defined_on_select_fun })
		end)
		local buffer = fiber.render(App)

		local selected_segment = assert(buffer:find_segment_by_position({ line = 1, col = 1 })) -- the first segment is selected

		selected_segment.interactions["SELECT"]()
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
