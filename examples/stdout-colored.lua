local Bufferline = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local ui = require("ascii-ui")
local useState = ui.hooks.useState
local useInterval = ui.hooks.useInterval
local StdoutViewport = ui.viewports.StdoutViewport

local WIDTH = 48
local HEIGHT = 20

local COLORS = {
	"#ff4466",
	"#ff8800",
	"#ffdd00",
	"#44ff88",
	"#00ccff",
	"#aa44ff",
}

local TRAIL_LEN = 8

--- @type ascii-ui.FunctionalComponent
local App = ui.createComponent("App", function()
	-- ball position and velocity
	local x, setX = useState(math.floor(WIDTH / 2))
	local y, setY = useState(math.floor(HEIGHT / 2))
	local dx, setDx = useState(1)
	local dy, setDy = useState(1)
	-- trail: list of { x, y } most-recent first
	local trail, setTrail = useState({})
	-- color index cycling
	local color_idx, setColorIdx = useState(1)

	useInterval(function()
		setX(function(cx)
			local nx = cx + dx
			if nx < 1 then
				nx = 2
				setDx(1)
				setColorIdx(function(ci)
					return (ci % #COLORS) + 1
				end)
			elseif nx > WIDTH then
				nx = WIDTH - 1
				setDx(-1)
				setColorIdx(function(ci)
					return (ci % #COLORS) + 1
				end)
			end
			return nx
		end)
		setY(function(cy)
			local ny = cy + dy
			if ny < 1 then
				ny = 2
				setDy(1)
				setColorIdx(function(ci)
					return (ci % #COLORS) + 1
				end)
			elseif ny > HEIGHT then
				ny = HEIGHT - 1
				setDy(-1)
				setColorIdx(function(ci)
					return (ci % #COLORS) + 1
				end)
			end
			return ny
		end)
		setTrail(function(t)
			local new_trail = { { x = x, y = y } }
			for i = 1, math.min(#t, TRAIL_LEN - 1) do
				table.insert(new_trail, t[i])
			end
			return new_trail
		end)
	end, 60)

	-- build a grid: cell = { char, fg }
	local grid = {}
	for row = 1, HEIGHT do
		grid[row] = {}
		for col = 1, WIDTH do
			grid[row][col] = { char = " ", fg = nil }
		end
	end

	-- paint trail with fading colors
	local ball_color = COLORS[color_idx]
	for i, pos in ipairs(trail) do
		if pos.y >= 1 and pos.y <= HEIGHT and pos.x >= 1 and pos.x <= WIDTH then
			-- fade: interpolate each channel toward black
			local fade = 1 - (i / (TRAIL_LEN + 1))
			local hex = ball_color
			local r = math.floor(tonumber(hex:sub(2, 3), 16) * fade)
			local g = math.floor(tonumber(hex:sub(4, 5), 16) * fade)
			local b = math.floor(tonumber(hex:sub(6, 7), 16) * fade)
			grid[pos.y][pos.x] = {
				char = "●",
				fg = ("#%02x%02x%02x"):format(r, g, b),
			}
		end
	end

	-- paint ball on top
	if y >= 1 and y <= HEIGHT and x >= 1 and x <= WIDTH then
		grid[y][x] = { char = "●", fg = ball_color }
	end

	-- convert grid to BufferLines
	local border_h = "+" .. ("-"):rep(WIDTH) .. "+"
	local lines = {}
	table.insert(lines, Bufferline.new(Segment:new({ content = border_h })))

	for row = 1, HEIGHT do
		local segments = { Segment:new({ content = "|" }) }
		for col = 1, WIDTH do
			local cell = grid[row][col]
			if cell.fg then
				table.insert(segments, Segment:new({ content = cell.char, color = { fg = cell.fg } }))
			else
				table.insert(segments, Segment:new({ content = cell.char }))
			end
		end
		table.insert(segments, Segment:new({ content = "|" }))
		table.insert(lines, Bufferline.new(unpack(segments)))
	end

	table.insert(lines, Bufferline.new(Segment:new({ content = border_h })))

	return lines
end)

ui.mount(App, StdoutViewport.new())
