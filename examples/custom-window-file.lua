-- Example: Custom Window that writes to a file
--
-- This example demonstrates how to create a completely custom window
-- that writes output to a file instead of rendering in a Neovim buffer.
-- This is useful for generating reports, logs, or static output.
--
-- Usage from within Neovim:
--   :luafile examples/custom-window-file.lua

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Box = ui.components.Box

-- Create a custom window that writes to a file
local function create_file_window(filepath)
	local Window = require("ascii-ui.window")
	local window = Window.new()

	local file

	-- Override the open method
	window.open = function(_self)
		-- Open file for writing
		file = io.open(filepath, "w")
		if not file then
			error("Failed to open file: " .. filepath)
		end

		-- Set dummy values (no actual Neovim window needed)
		_self.winid = -1
		_self.bufnr = -1

		-- Write header
		file:write(string.rep("=", 60) .. "\n")
		file:write("ASCII-UI Custom Window - File Output\n")
		file:write("Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
		file:write(string.rep("=", 60) .. "\n\n")
	end

	-- Override update to write buffer contents to file
	window.update = function(_self, buffer)
		if not buffer or not file then
			return
		end

		-- Convert buffer to text lines
		local lines = {}
		for i = 1, buffer.height do
			local line = buffer.lines[i]
			if line then
				local text_parts = {}
				for _, segment in ipairs(line.segments) do
					table.insert(text_parts, segment.text)
				end
				table.insert(lines, table.concat(text_parts, ""))
			else
				table.insert(lines, "")
			end
		end

		-- Clear previous content and write new content
		file:seek("set", 0)
		file:write(string.rep("=", 60) .. "\n")
		file:write("ASCII-UI Custom Window - File Output\n")
		file:write("Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
		file:write(string.rep("=", 60) .. "\n\n")

		for _, line in ipairs(lines) do
			file:write(line .. "\n")
		end

		file:write("\n" .. string.rep("-", 60) .. "\n")
		file:flush()
	end

	-- Override close to close the file
	window.close = function(self)
		if file then
			file:write("\n" .. string.rep("=", 60) .. "\n")
			file:write("Output Complete\n")
			file:write(string.rep("=", 60) .. "\n")
			file:close()
		end

		self.winid = nil
		self.bufnr = nil
	end

	-- Override methods that check window state
	window.is_close = function(self)
		return self.winid == nil
	end

	-- Disable interactive features
	window.enable_edits = function(_self) end
	window.disable_edits = function(_self) end

	return window
end

-- Example: Generate a status report
local StatusReport = ui.createComponent(function()
	local status, set_status = ui.hooks.useState("Initializing...")
	local progress, set_progress = ui.hooks.useState(0)

	ui.hooks.useEffect(function()
		local steps = {
			{ delay = 500, status = "Loading configuration...", progress = 25 },
			{ delay = 1000, status = "Processing data...", progress = 50 },
			{ delay = 1500, status = "Generating report...", progress = 75 },
			{ delay = 2000, status = "Complete!", progress = 100 },
		}

		local function run_step(index)
			if index > #steps then
				return
			end

			local step = steps[index]
			vim.defer_fn(function()
				set_status(step.status)
				set_progress(step.progress)
				run_step(index + 1)
			end, step.delay)
		end

		run_step(1)
	end, {})

	local progress_bar = string.rep("█", math.floor(progress / 5)) .. string.rep("░", 20 - math.floor(progress / 5))

	return Box({
		padding = 2,
		border = "rounded",
		children = {
			Paragraph({
				text = [[System Status Report
====================

Status: ]] .. status .. [[


Progress: ]] .. progress .. [[%
]] .. progress_bar .. [[


This report is being written to:
  /tmp/ascii-ui-report.txt

The file updates automatically as the
status changes.]],
			}),
		},
	})
end)

-- Create the custom file window
local output_file = "/tmp/ascii-ui-report.txt"
local file_window = create_file_window(output_file)

-- Mount the component
ui.mount(StatusReport, file_window)

-- Print confirmation
print("\n✓ Component mounted!")
print("✓ Output file: " .. output_file)
print("\nThe file will update automatically as the component re-renders.")
print("You can watch it with: tail -f " .. output_file)
print("\nClose the window with :q to finalize the output.\n")
