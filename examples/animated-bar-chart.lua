local BufferLine = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState
local useInterval = ui.hooks.useInterval

-- ============================================================================
-- DATA LAYER: Color and character mapping
-- ============================================================================

--- Get color for a bar based on value and max value
--- @param value number Current value
--- @param max_value number Maximum value
--- @return string color Hex color code
local function get_bar_color(value, max_value)
	local ratio = max_value > 0 and (value / max_value) or 0
	if ratio >= 0.8 then
		return "#39d353" -- bright green (high)
	elseif ratio >= 0.6 then
		return "#26a641" -- green (medium-high)
	elseif ratio >= 0.4 then
		return "#006d32" -- medium green (medium)
	elseif ratio >= 0.2 then
		return "#0e4429" -- dark green (low)
	else
		return "#161b22" -- very dark (very low)
	end
end

-- ============================================================================
-- LOGIC LAYER: Data processing and calculations
-- ============================================================================

--- Generate random data for bars
--- @param count number Number of bars
--- @return number[] values Array of values (0-100)
local function generate_random_data(count)
	local values = {}
	for i = 1, count do
		values[i] = math.random(0, 100)
	end
	return values
end

--- Update data with smooth transitions
--- @param current_values number[] Current values
--- @return number[] new_values Updated values
local function update_data_smoothly(current_values)
	local new_values = {}
	for i, current_value in ipairs(current_values) do
		-- Generate target value
		local target = math.random(0, 100)
		-- Smooth transition: move 10% towards target
		local diff = target - current_value
		new_values[i] = math.max(0, math.min(100, current_value + diff * 0.1))
	end
	return new_values
end

-- ============================================================================
-- VISUALIZATION LAYER: Render bar chart
-- ============================================================================

--- Render complete bar chart
--- @param values number[] Array of bar values
--- @param labels string[] Array of bar labels
--- @param bar_height number Height of bars
--- @return ascii-ui.BufferLine[] chart_lines
local function render_bar_chart(values, labels, bar_height)
	local max_value = 100 -- Fixed max for color calculation
	local num_bars = #values
	local chart_lines = {}
	local column_width = 3 -- Each column is 3 characters wide (bar + 2 spaces for alignment)

	-- Render bar section (from top to bottom)
	for row = bar_height, 1, -1 do
		local row_segments = {}

		for bar_idx = 1, num_bars do
			local value = values[bar_idx]
			local bar_value_height = math.ceil((value / 100) * bar_height)

			-- Each column is 3 characters: [space][bar][space]
			-- This centers the bar in the column to align with 2-char labels
			if row <= bar_value_height then
				local color = get_bar_color(value, max_value)
				-- Left space
				table.insert(row_segments, Segment:new({ content = " " }))
				-- Bar (centered)
				table.insert(row_segments, Segment:new({ content = " ", color = { bg = color } }))
				-- Right space
				table.insert(row_segments, Segment:new({ content = " " }))
			else
				-- Empty space above the bar (3 spaces to match column width)
				table.insert(row_segments, Segment:new({ content = "   " }))
			end

			-- No additional spacing - column is already 3 chars wide
		end

		table.insert(chart_lines, BufferLine.new(unpack(row_segments)))
	end

	-- Render label row (each column: [space][2-char label] = 3 chars, matching bar structure)
	local label_row_segments = {}
	for bar_idx = 1, num_bars do
		local label = labels[bar_idx] or tostring(bar_idx)
		-- Use first 2 characters, pad if needed
		local label_text = label:sub(1, 2)
		if #label_text < 2 then
			label_text = label_text .. " "
		end
		-- Match bar structure: [space][2-char label] = 3 chars
		table.insert(label_row_segments, Segment:new({ content = " " }))
		table.insert(label_row_segments, Segment:new({ content = label_text, color = { fg = "#8b949e" } }))

		-- No additional spacing - already 3 chars per column
	end
	table.insert(chart_lines, BufferLine.new(unpack(label_row_segments)))

	-- Render value row (each column: [space][2-char value] = 3 chars, matching bar structure)
	local value_row_segments = {}
	for bar_idx = 1, num_bars do
		local value = values[bar_idx]
		local value_text = tostring(math.floor(value))
		-- Pad to exactly 2 characters: right-align numbers in 2-char space
		if #value_text == 1 then
			value_text = " " .. value_text
		elseif #value_text > 2 then
			value_text = value_text:sub(1, 2)
		end
		-- Match bar structure: [space][2-char value] = 3 chars
		table.insert(value_row_segments, Segment:new({ content = " " }))
		table.insert(value_row_segments, Segment:new({ content = value_text, color = { fg = "#E0E0E0" } }))

		-- No additional spacing - already 3 chars per column
	end
	table.insert(chart_lines, BufferLine.new(unpack(value_row_segments)))

	return chart_lines
end

-- ============================================================================
-- COMPONENT LAYER: React-like components
-- ============================================================================

--- Component that displays an animated bar chart
--- @param props { labels?: string[], bar_height?: number, update_interval?: number, num_bars?: number }
local function AnimatedBarChart(props)
	props = props or {}
	local labels = props.labels or {}
	local bar_height = props.bar_height or 10
	local update_interval = props.update_interval or 200 -- milliseconds
	local num_bars = props.num_bars or #labels

	-- Generate initial labels if not provided
	if #labels == 0 then
		for i = 1, num_bars do
			labels[i] = "Bar" .. i
		end
	end

	-- Initialize with random data
	local initial_values = generate_random_data(num_bars)
	local values, setValues = useState(initial_values)

	-- Update values smoothly
	useInterval(function()
		setValues(update_data_smoothly(values))
	end, update_interval)

	-- Render chart
	return render_bar_chart(values, labels, bar_height)
end

local AnimatedBarChartComponent = ui.createComponent("AnimatedBarChart", AnimatedBarChart, {
	labels = "table",
	bar_height = "number",
	update_interval = "number",
	num_bars = "number",
})

--- @type ascii-ui.FunctionalComponent
local App = ui.createComponent("App", function()
	return {
		Paragraph({ content = "=== Animated Bar Chart ===" }),
		Paragraph({ content = "" }),
		Paragraph({ content = "Sales by Month (updates every 200ms):" }),
		AnimatedBarChartComponent({
			labels = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" },
			bar_height = 12,
			update_interval = 200,
		}),
		Paragraph({ content = "" }),
		Paragraph({ content = "CPU Usage by Core (updates every 150ms):" }),
		AnimatedBarChartComponent({
			labels = { "Core1", "Core2", "Core3", "Core4", "Core5", "Core6", "Core7", "Core8" },
			bar_height = 10,
			update_interval = 150,
		}),
		Paragraph({ content = "" }),
		Paragraph({ content = "Random Data (updates every 100ms):" }),
		AnimatedBarChartComponent({
			num_bars = 15,
			bar_height = 8,
			update_interval = 100,
		}),
	}
end)

ui.mount(App)
