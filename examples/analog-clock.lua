local BufferLine = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState
local useInterval = ui.hooks.useInterval

-- ============================================================================
-- DATA LAYER: Time calculations
-- ============================================================================

--- Get current time
--- @return number hour, number minute, number second
local function get_current_time()
	local now = os.date("*t")
	return now.hour, now.min, now.sec
end

-- ============================================================================
-- LOGIC LAYER: Clock hand calculations
-- ============================================================================

--- Calculate angle for hour hand (0-360 degrees, 0 = 12 o'clock)
--- @param hour number Hour (0-23)
--- @param minute number Minute (0-59)
--- @return number angle Angle in degrees
local function hour_angle(hour, minute)
	-- Convert 24-hour to 12-hour format
	local hour_12 = hour % 12
	-- Each hour is 30 degrees, plus minute contribution
	return (hour_12 * 30) + (minute * 0.5)
end

--- Calculate angle for minute hand (0-360 degrees, 0 = 12 o'clock)
--- @param minute number Minute (0-59)
--- @param second number Second (0-59)
--- @return number angle Angle in degrees
local function minute_angle(minute, second)
	-- Each minute is 6 degrees, plus second contribution
	return (minute * 6) + (second * 0.1)
end

--- Calculate angle for second hand (0-360 degrees, 0 = 12 o'clock)
--- @param second number Second (0-59)
--- @return number angle Angle in degrees
local function second_angle(second)
	-- Each second is 6 degrees
	return second * 6
end

--- Convert angle to radians
--- @param degrees number Angle in degrees
--- @return number radians
local function to_radians(degrees)
	return degrees * math.pi / 180
end

--- Calculate position on circle (compensating for character aspect ratio)
--- @param center_x number Center X coordinate
--- @param center_y number Center Y coordinate
--- @param radius number Radius
--- @param angle_degrees number Angle in degrees
--- @return number x, number y
local function position_on_circle(center_x, center_y, radius, angle_degrees)
	local angle = to_radians(angle_degrees - 90) -- -90 to start at top (12 o'clock)
	-- Compensate for character aspect ratio (characters are ~2x taller than wide)
	-- Multiply x by aspect_ratio to make circle appear round
	local aspect_ratio = 2.0
	local x = center_x + radius * math.cos(angle) * aspect_ratio
	local y = center_y + radius * math.sin(angle)
	return math.floor(x + 0.5), math.floor(y + 0.5) -- Round to nearest integer
end

-- ============================================================================
-- VISUALIZATION LAYER: Render analog clock
-- ============================================================================

--- Draw a line from (x1, y1) to (x2, y2) on the grid
--- @param grid table 2D grid (stores {char, color} tables)
--- @param x1 number Start X
--- @param y1 number Start Y
--- @param x2 number End X
--- @param y2 number End Y
--- @param char string Character to use for the line
--- @param color string Color for the line
--- @param width number Grid width
--- @param height number Grid height
local function draw_line(grid, x1, y1, x2, y2, char, color, width, height)
	local dx = math.abs(x2 - x1)
	local dy = math.abs(y2 - y1)
	local sx = x1 < x2 and 1 or -1
	local sy = y1 < y2 and 1 or -1
	local err = dx - dy

	local x, y = x1, y1
	while true do
		if x >= 1 and x <= width and y >= 1 and y <= height then
			-- Don't overwrite center dot or hour markers
			local current = grid[y][x]
			if current.char ~= "O" and current.char ~= "+" then
				-- If there's already a hand character, prefer the thicker one
				if
					char == "#"
					or (char == "*" and current.char ~= "#")
					or (char == "|" and current.char ~= "#" and current.char ~= "*")
				then
					grid[y][x] = { char = char, color = color }
				end
			end
		end

		if x == x2 and y == y2 then
			break
		end

		local e2 = 2 * err
		if e2 > -dy then
			err = err - dy
			x = x + sx
		end
		if e2 < dx then
			err = err + dx
			y = y + sy
		end
	end
end

--- Render analog clock face
--- @param hour number Current hour
--- @param minute number Current minute
--- @param second number Current second
--- @param size number Size of clock (radius in characters)
--- @return ascii-ui.BufferLine[] clock_lines
local function render_analog_clock(hour, minute, second, size)
	size = size or 10
	local aspect_ratio = 2.0 -- Characters are ~2x taller than wide
	local center_x = math.floor(size * aspect_ratio) + 1
	local center_y = size + 1
	local radius = size

	local clock_lines = {}
	local grid = {}

	-- Color palette
	local colors = {
		face = "#4A90E2", -- Blue for clock face
		markers = "#FFD700", -- Gold for hour markers
		hour_hand = "#FF6B6B", -- Red for hour hand
		minute_hand = "#4ECDC4", -- Cyan for minute hand
		second_hand = "#FFE66D", -- Yellow for second hand
		center = "#FFFFFF", -- White for center
		background = nil, -- No background color
	}

	-- Initialize grid (wider to accommodate aspect ratio compensation)
	-- Grid stores {char, color} tables
	local width = math.floor(size * aspect_ratio * 2) + 3
	local height = size * 2 + 3
	for y = 1, height do
		grid[y] = {}
		for x = 1, width do
			grid[y][x] = { char = " ", color = colors.background }
		end
	end

	-- Draw clock face (circle outline with dots)
	for angle = 0, 360, 6 do
		local x, y = position_on_circle(center_x, center_y, radius, angle)
		if x >= 1 and x <= width and y >= 1 and y <= height then
			grid[y][x] = { char = ".", color = colors.face }
		end
	end

	-- Draw hour markers (12, 3, 6, 9) - use single character
	local hour_markers = {
		{ angle = 0, char = "+" }, -- 12 o'clock (top)
		{ angle = 90, char = "+" }, -- 3 o'clock (right)
		{ angle = 180, char = "+" }, -- 6 o'clock (bottom)
		{ angle = 270, char = "+" }, -- 9 o'clock (left)
	}
	for _, marker in ipairs(hour_markers) do
		local x, y = position_on_circle(center_x, center_y, radius, marker.angle)
		if x >= 1 and x <= width and y >= 1 and y <= height then
			grid[y][x] = { char = marker.char, color = colors.markers }
		end
	end

	-- Draw hour hand (thick, shorter)
	local hour_ang = hour_angle(hour, minute)
	local hour_radius = radius * 0.5
	local hour_x, hour_y = position_on_circle(center_x, center_y, hour_radius, hour_ang)
	draw_line(grid, center_x, center_y, hour_x, hour_y, "#", colors.hour_hand, width, height)

	-- Draw minute hand (medium, longer)
	local minute_ang = minute_angle(minute, second)
	local minute_radius = radius * 0.75
	local minute_x, minute_y = position_on_circle(center_x, center_y, minute_radius, minute_ang)
	draw_line(grid, center_x, center_y, minute_x, minute_y, "*", colors.minute_hand, width, height)

	-- Draw second hand (thin, longest)
	local second_ang = second_angle(second)
	local second_radius = radius * 0.85
	local second_x, second_y = position_on_circle(center_x, center_y, second_radius, second_ang)
	draw_line(grid, center_x, center_y, second_x, second_y, "|", colors.second_hand, width, height)

	-- Center dot
	grid[center_y][center_x] = { char = "O", color = colors.center }

	-- Convert grid to BufferLines with colors
	for y = 1, height do
		local segments = {}
		local current_segment = { content = "", color = nil }

		for x = 1, width do
			local cell = grid[y][x]
			local char = cell.char
			local color = cell.color

			-- Group consecutive characters with the same color
			if color == current_segment.color then
				current_segment.content = current_segment.content .. char
			else
				-- Save previous segment if it has content
				if current_segment.content ~= "" then
					local segment_opts = { content = current_segment.content }
					if current_segment.color then
						segment_opts.color = { fg = current_segment.color }
					end
					table.insert(segments, Segment:new(segment_opts))
				end
				-- Start new segment
				current_segment = { content = char, color = color }
			end
		end

		-- Add last segment
		if current_segment.content ~= "" then
			local segment_opts = { content = current_segment.content }
			if current_segment.color then
				segment_opts.color = { fg = current_segment.color }
			end
			table.insert(segments, Segment:new(segment_opts))
		end

		-- Create BufferLine with segments (handle empty case)
		if #segments > 0 then
			table.insert(clock_lines, BufferLine.new(unpack(segments)))
		else
			-- Empty line with a space segment
			table.insert(clock_lines, BufferLine.new(Segment:new({ content = " " })))
		end
	end

	return clock_lines
end

-- ============================================================================
-- COMPONENT LAYER: React-like components
-- ============================================================================

--- Component that displays an analog clock
--- @param props { size?: number }
local function AnalogClock(props)
	props = props or {}
	local size = props.size or 10

	local hour, minute, second = get_current_time()
	local time_state, setTime = useState({ hour = hour, minute = minute, second = second })

	-- Update time every second
	useInterval(function()
		local h, m, s = get_current_time()
		setTime({ hour = h, minute = m, second = s })
	end, 1000)

	return render_analog_clock(time_state.hour, time_state.minute, time_state.second, size)
end

local AnalogClockComponent = ui.createComponent("AnalogClock", AnalogClock, {
	size = "number",
})

--- @type ascii-ui.FunctionalComponent
local App = ui.createComponent("App", function()
	local hour, minute, second = get_current_time()
	local time_state, setTime = useState({ hour = hour, minute = minute, second = second })

	-- Update time every second
	useInterval(function()
		local h, m, s = get_current_time()
		setTime({ hour = h, minute = m, second = s })
	end, 1000)

	local time_str = string.format("%02d:%02d:%02d", time_state.hour, time_state.minute, time_state.second)

	return {
		BufferLine.new(Segment:new({ content = "=== Analog Clock ===", color = { fg = "#FFD700" } })),
		Paragraph({ content = "" }),
		BufferLine.new(Segment:new({ content = "Current time: " .. time_str, color = { fg = "#4ECDC4" } })),
		Paragraph({ content = "" }),
		AnalogClockComponent({
			size = 12,
		}),
		Paragraph({ content = "" }),
		BufferLine.new(Segment:new({
			content = "Legend: # = Hour (Red)  * = Minute (Cyan)  | = Second (Yellow)",
			color = { fg = "#8b949e" },
		})),
	}
end)

ui.mount(App)
