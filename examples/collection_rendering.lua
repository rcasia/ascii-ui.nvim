local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Column = ui.layout.Column
local Button = ui.components.Button
local For = ui.components.For
local useReducer = ui.hooks.useReducer

--- @type ascii-ui.FunctionalComponent
local App = ui.createComponent("App", function()
	return function()
		local items, dispatch = useReducer(function(state, action)
			if action.type == "add" then
				return vim.list_extend(state, { "this is " .. #state + 1 })
			end
			return state
		end, { "this is 1", "this is 2" })

		return Column(
			Paragraph({
				content = function()
					return "There are " .. #items() .. " items in the list"
				end,
			}),
			For({
				items = items,
				transform = function(item)
					return { content = item }
				end,
				component = Paragraph,
			}),

			Button({
				label = "Add more",
				on_press = function()
					dispatch({ type = "add" })
				end,
			})
		)
	end
end)

ui.mount(App)
