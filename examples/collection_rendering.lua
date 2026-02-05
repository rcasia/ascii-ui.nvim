local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useReducer = ui.hooks.useReducer

--- @type ascii-ui.FunctionalComponent
local App = ui.createComponent("App", function()
	local items, dispatch = useReducer(function(state, action)
		if action.type == "add" then
			return vim.list_extend(state, { "this is " .. #state + 1 })
		end
		return state
	end, { "this is 1", "this is 2" })

	return {
		Paragraph({
			content = "There are " .. #items .. " items in the list",
		}),
		ui.map(items, function(item)
			return Paragraph({ content = item })
		end),
		Button({
			label = "Add more",
			on_press = function()
				dispatch({ type = "add" })
			end,
		}),
	}
end)

ui.mount(App)
