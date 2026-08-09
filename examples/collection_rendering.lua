local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useState = ui.hooks.useState

local function App()
	local items, setItems = useState({ "Learn ascii-ui", "Build something cool", "Share with others" })
	return {
		Paragraph({ content = "Todo (" .. #items .. " items)" }),
		ui.map(items, function(item, i)
			return Paragraph({ content = i .. ". " .. item })
		end),
		Button({
			label = "Add item",
			on_press = function()
				setItems(function(prev)
					local new = vim.list_extend({}, prev)
					table.insert(new, "New item #" .. (#prev + 1))
					return new
				end)
			end,
		}),
	}
end

ui.mount(ui.createComponent("App", App))
