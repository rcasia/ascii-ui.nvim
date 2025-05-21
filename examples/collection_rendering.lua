local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Layout = ui.layout
local Button = ui.components.Button
local For = require("ascii-ui.directives.for")

--- @type ascii-ui.FunctionalComponent
local function App()
	local items, dispatch = ui.hooks.useReducer(function(state, action)
		if action.type == "add" then
			return vim.list_extend(state, { "this is " .. #state + 1 })
		end
		return state
	end, { "this is 1", "this is 2" })

	return Layout(
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

ui.mount(App())
