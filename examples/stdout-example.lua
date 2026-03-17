-- Example: Custom Window that writes to stdout
--
-- This example demonstrates how to create a completely custom window
-- that writes output directly to stdout instead of rendering in a Neovim buffer.
--
-- Usage from within Neovim:
--   :luafile examples/stdout-example.lua
--
-- Or from terminal (requires ascii-ui in your runtimepath):
--   nvim -l examples/stdout-example.lua
--
-- Custom Window Pattern:
-- ----------------------
-- To create a custom window, you need to:
-- 1. Create a base Window object using Window.new()
-- 2. Override the following methods:
--    - open()    : Initialize your custom output (file, socket, stdout, etc.)
--    - update()  : Called when the component re-renders with new buffer content
--    - close()   : Clean up resources when the window closes
--    - is_close(): Return whether the window is closed
-- 3. Set self.winid and self.bufnr (can be dummy values like -1)
-- 4. Optionally disable interactive features (enable_edits, disable_edits)

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Box = ui.components.Box

-- Create a custom window implementation
local function create_stdout_window()
	local Window = require("ascii-ui.window")
	local window = Window.new()

	-- Override the open method to do nothing (no Neovim window needed)
	window.open = function(_self)
		-- Set dummy values
		_self.winid = -1
		_self.bufnr = -1

		-- Print header to stdout
		print("\n" .. string.rep("=", 50))
		print("ASCII-UI Custom Window - stdout Example")
		print(string.rep("=", 50) .. "\n")
	end

	-- Override update to write buffer contents to stdout
	window.update = function(_self, buffer)
		if not buffer then
			return
		end

		-- Clear screen (optional - comment out if you don't want this)
		-- io.write("\027[2J\027[H")

		-- Get all lines from the buffer
		local lines = {}
		for i = 1, buffer.height do
			local line = buffer.lines[i]
			if line then
				-- Convert buffer line segments to plain text
				local text_parts = {}
				for _, segment in ipairs(line.segments) do
					table.insert(text_parts, segment.text)
				end
				table.insert(lines, table.concat(text_parts, ""))
			else
				table.insert(lines, "")
			end
		end

		-- Write to stdout
		for _, line in ipairs(lines) do
			print(line)
		end

		print("\n" .. string.rep("-", 50))
	end

	-- Override close to print footer
	window.close = function(self)
		print("\n" .. string.rep("=", 50))
		print("Window Closed")
		print(string.rep("=", 50) .. "\n")

		self.winid = nil
		self.bufnr = nil
	end

	-- Override methods that check window state
	window.is_close = function(self)
		return self.winid == nil
	end

	-- Disable interactive features (no keymaps needed for stdout)
	window.enable_edits = function(_self) end
	window.disable_edits = function(_self) end

	return window
end

-- Example component
local Counter = ui.createComponent(function()
	local count, set_count = ui.hooks.useState(0)

	ui.hooks.useEffect(function()
		-- Auto-increment counter every 500ms
		local timer = vim.loop.new_timer()
		timer:start(
			500,
			500,
			vim.schedule_wrap(function()
				set_count(count + 1)
			end)
		)

		return function()
			timer:stop()
			timer:close()
		end
	end, { count })

	return Box({
		padding = 2,
		border = "rounded",
		children = {
			Paragraph({
				text = [[Counter Demo

Current count: ]] .. count .. [[


This is rendering to stdout!
Updates every 500ms]],
			}),
		},
	})
end)

-- Mount with custom stdout window
local custom_window = create_stdout_window()
ui.mount(Counter, custom_window)

-- Keep the script running for a few seconds to see updates
vim.defer_fn(function()
	-- Close the window after 5 seconds
	vim.api.nvim_buf_delete(vim.api.nvim_list_bufs()[1], { force = true })
	print("\nExample complete! The component rendered " .. 10 .. " times.")
	vim.cmd("quit")
end, 5000)
