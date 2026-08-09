local BufferLine = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState
local useInterval = ui.hooks.useInterval

local COLORS = {
	GREEN = "#00C853",
	BLUE = "#1976D2",
	RED = "#D32F2F",
	CURRENT = "#FFD700",
	TEXT_DIM = "#E0E0E0",
}

local function MetroLine(props)
	local stations = props.stations
	local color = props.color or COLORS.BLUE
	local current, setCurrent = useState(1)

	useInterval(function()
		setCurrent(function(c)
			return (c % #stations) + 1
		end)
	end, props.speed or 2000)

	local max_len = 0
	for _, s in ipairs(stations) do
		if #s > max_len then
			max_len = #s
		end
	end
	local col_w = math.max(max_len + 2, 10)

	local points = { Segment:new({ content = "│", color = { fg = color } }) }
	local names = { Segment:new({ content = " " }) }

	for i, station in ipairs(stations) do
		local is_cur = i == current
		points[#points + 1] = Segment:new({
			content = is_cur and "●" or "○",
			color = is_cur and { fg = COLORS.CURRENT, bg = color } or { fg = color },
		})
		if i < #stations then
			points[#points + 1] = Segment:new({ content = ("─"):rep(col_w - 1), color = { fg = color } })
		end

		local name = station .. (" "):rep(math.max(0, col_w - 1 - #station))
		names[#names + 1] = Segment:new({
			content = name,
			color = is_cur and { fg = "#FFFFFF", bg = "#1a1a1a" } or { fg = COLORS.TEXT_DIM },
		})
		if i < #stations then
			names[#names + 1] = Segment:new({ content = " " })
		end
	end

	return { BufferLine.new(unpack(points)), BufferLine.new(unpack(names)) }
end

local MetroLineComp = ui.createComponent("MetroLine", MetroLine, {
	stations = "table",
	color = "string",
	speed = "number",
})

local App = ui.createComponent("App", function()
	return {
		Paragraph({ content = "=== Metro Map ===" }),
		Paragraph({ content = "" }),
		MetroLineComp({
			stations = { "Central", "Main Square", "University", "Park", "Airport" },
			color = COLORS.GREEN,
			speed = 1500,
		}),
		Paragraph({ content = "" }),
		MetroLineComp({
			stations = { "North", "Center", "South" },
			color = COLORS.BLUE,
			speed = 2000,
		}),
		Paragraph({ content = "" }),
		MetroLineComp({
			stations = { "East", "West" },
			color = COLORS.RED,
			speed = 1800,
		}),
	}
end)

ui.mount(App)
