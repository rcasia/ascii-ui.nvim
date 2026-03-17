-- Example showing how to use a fullscreen window
-- Run this with: :luafile examples/fullscreen-example.lua

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useState = ui.hooks.useState

--- @type ascii-ui.FunctionalComponent
local Dashboard = ui.createComponent("Dashboard", function()
	local time, setTime = useState(os.date("%H:%M:%S"))

	-- Update time every second
	ui.hooks.useInterval(function()
		setTime(os.date("%H:%M:%S"))
	end, 1000)

	return {
		Paragraph({ content = "==========================" }),
		Paragraph({ content = "   Dashboard - " .. time }),
		Paragraph({ content = "==========================" }),
		Paragraph({ content = "" }),
		Paragraph({ content = "Welcome to the fullscreen dashboard!" }),
		Paragraph({ content = "" }),
		Paragraph({ content = "System Status: Online" }),
		Paragraph({ content = "Active Users: 42" }),
		Paragraph({ content = "CPU Usage: 45%" }),
		Paragraph({ content = "Memory: 8.2 GB / 16 GB" }),
		Paragraph({ content = "" }),
		Button({
			label = "Refresh",
			on_press = function()
				print("Refreshing...")
			end,
		}),
	}
end)

-- Create a fullscreen window
local fullscreen_window = ui.window.fullscreen.create()

ui.mount(Dashboard, fullscreen_window)
