-- Example demonstrating different window types
-- Run this with: :luafile examples/window-types.lua

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useState = ui.hooks.useState

--- @type ascii-ui.FunctionalComponent
local App = ui.createComponent("App", function()
	local count, setCount = useState(0)
	return {
		Paragraph({ content = "===== Window Types Demo =====" }),
		Paragraph({ content = "" }),
		Paragraph({ content = "Button pressed: " .. count .. " times" }),
		Paragraph({ content = "" }),
		Button({
			label = "Increment",
			on_press = function()
				setCount(count + 1)
			end,
		}),
	}
end)

-- Example 1: Default floating window (centered)
print("Example 1: Default floating window")
-- ui.mount(App)

-- Example 2: Custom positioned floating window
print("Example 2: Floating window at top-left")
-- Uncomment to test:
-- local floating_window = ui.window.floating.create({
-- 	width = 50,
-- 	height = 15,
-- 	row = 2,
-- 	col = 5,
-- 	border = "double",
-- })
-- ui.mount(App, floating_window)

-- Example 3: Split window (right sidebar)
print("Example 3: Right split window")
local split_window = ui.window.split.create({
	position = "right",
	size = 50,
})
-- ui.mount(App, split_window)

-- Example 4: Split window (left sidebar)
print("Example 4: Left split window")
-- local left_split = ui.window.split.create({
-- 	position = "left",
-- 	size = 40,
-- })
-- ui.mount(App, left_split)

-- Example 5: Split window (bottom panel)
print("Example 5: Bottom split window")
-- local bottom_split = ui.window.split.create({
-- 	position = "bottom",
-- 	size = 10,
-- })
-- ui.mount(App, bottom_split)

-- Example 6: Fullscreen window
print("Example 6: Fullscreen window")
-- local fullscreen = ui.window.fullscreen.create()
-- ui.mount(App, fullscreen)

-- Example 7: User-provided buffer
print("Example 7: Custom buffer")
-- local bufnr = vim.api.nvim_create_buf(false, true)
-- vim.cmd("split")
-- vim.api.nvim_win_set_buf(0, bufnr)
-- local buffer_window = ui.window.buffer.create({ bufnr = bufnr })
-- ui.mount(App, buffer_window)

-- Uncomment one of the above examples to test!
-- For demonstration, we'll use the right split:
ui.mount(App, split_window)
