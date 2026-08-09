-- Advanced example: animated analog clock with colored hands.
-- See simpler examples first (example-1.lua, use-interval.lua).

local BufferLine = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState
local useInterval = ui.hooks.useInterval

local COLORS = {
	FACE = "#4A90E2",
	MARKERS = "#FFD700",
	HOUR = "#FF6B6B",
	MINUTE = "#4ECDC4",
	SECOND = "#FFE66D",
	CENTER = "#FFFFFF",
	LEGEND = "#8b949e",
}

local function get_time()
	local now = os.date("*t")
	return now.hour, now.min, now.sec
end

local function to_radians(deg)
	return deg * math.pi / 180
end

local function pos_on_circle(cx, cy, r, angle_deg)
	local a = to_radians(angle_deg - 90)
	local x = cx + r * math.cos(a) * 2.0
	local y = cy + r * math.sin(a)
	return math.floor(x + 0.5), math.floor(y + 0.5)
end

local function draw_line(grid, x1, y1, x2, y2, char, color, w, h)
	local dx = math.abs(x2 - x1)
	local dy = math.abs(y2 - y1)
	local sx = x1 < x2 and 1 or -1
	local sy = y1 < y2 and 1 or -1
	local err = dx - dy
	local x, y = x1, y1
	while true do
		if x >= 1 and x <= w and y >= 1 and y <= h then
			local cur = grid[y][x]
			if cur.char ~= "O" and cur.char ~= "+" then
				if
					char == "#"
					or (char == "*" and cur.char ~= "#")
					or (char == "|" and cur.char ~= "#" and cur.char ~= "*")
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

local function render_clock(hour, minute, second, size)
	local ar = 2.0
	local cx = math.floor(size * ar) + 1
	local cy = size + 1
	local w = math.floor(size * ar * 2) + 3
	local h = size * 2 + 3

	local grid = {}
	for y = 1, h do
		grid[y] = {}
		for x = 1, w do
			grid[y][x] = { char = " ", color = nil }
		end
	end

	for angle = 0, 360, 6 do
		local x, y = pos_on_circle(cx, cy, size, angle)
		if x >= 1 and x <= w and y >= 1 and y <= h then
			grid[y][x] = { char = ".", color = COLORS.FACE }
		end
	end

	for _, m in ipairs({ { 0 }, { 90 }, { 180 }, { 270 } }) do
		local x, y = pos_on_circle(cx, cy, size, m[1])
		if x >= 1 and x <= w and y >= 1 and y <= h then
			grid[y][x] = { char = "+", color = COLORS.MARKERS }
		end
	end

	local ha = (hour % 12) * 30 + minute * 0.5
	local hx, hy = pos_on_circle(cx, cy, size * 0.5, ha)
	draw_line(grid, cx, cy, hx, hy, "#", COLORS.HOUR, w, h)

	local ma = minute * 6 + second * 0.1
	local mx, my = pos_on_circle(cx, cy, size * 0.75, ma)
	draw_line(grid, cx, cy, mx, my, "*", COLORS.MINUTE, w, h)

	local sa = second * 6
	local sx2, sy2 = pos_on_circle(cx, cy, size * 0.85, sa)
	draw_line(grid, cx, cy, sx2, sy2, "|", COLORS.SECOND, w, h)

	grid[cy][cx] = { char = "O", color = COLORS.CENTER }

	local lines = {}
	for y = 1, h do
		local segments = {}
		local cur = { content = "", color = nil }
		for x = 1, w do
			local cell = grid[y][x]
			if cell.color == cur.color then
				cur.content = cur.content .. cell.char
			else
				if cur.content ~= "" then
					local opts = { content = cur.content }
					if cur.color then
						opts.color = cur.color
					end
					table.insert(segments, Segment:new(opts))
				end
				cur = { content = cell.char, color = cell.color }
			end
		end
		if cur.content ~= "" then
			local opts = { content = cur.content }
			if cur.color then
				opts.color = cur.color
			end
			table.insert(segments, Segment:new(opts))
		end
		if #segments > 0 then
			table.insert(lines, BufferLine.new(unpack(segments)))
		else
			table.insert(lines, BufferLine.new(Segment:new({ content = " " })))
		end
	end
	return lines
end

local AnalogClock = ui.createComponent("AnalogClock", function(props)
	local size = (props and props.size) or 10
	local h, m, s = get_time()
	local time, setTime = useState({ hour = h, minute = m, second = s })
	useInterval(function()
		local hh, mm, ss = get_time()
		setTime({ hour = hh, minute = mm, second = ss })
	end, 1000)
	return render_clock(time.hour, time.minute, time.second, size)
end, { size = "number" })

local App = ui.createComponent("App", function()
	local h, m, s = get_time()
	local time, setTime = useState({ hour = h, minute = m, second = s })
	useInterval(function()
		local hh, mm, ss = get_time()
		setTime({ hour = hh, minute = mm, second = ss })
	end, 1000)
	local time_str = string.format("%02d:%02d:%02d", time.hour, time.minute, time.second)
	return {
		BufferLine.new(Segment:new({ content = "=== Analog Clock ===", color = COLORS.MARKERS })),
		Paragraph({ content = "" }),
		BufferLine.new(Segment:new({ content = "Current time: " .. time_str, color = COLORS.MINUTE })),
		Paragraph({ content = "" }),
		AnalogClock({ size = 12 }),
		Paragraph({ content = "" }),
		BufferLine.new(Segment:new({
			content = "Legend: # = Hour  * = Minute  | = Second",
			color = COLORS.LEGEND,
		})),
	}
end)

ui.mount(App)
