local BufferLine = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState
local useInterval = ui.hooks.useInterval

--- Component that displays a metro map with lines and stations
--- @param props { stations: string[], current_station: number, line_color?: string }
local function MetroMap(props)
	props = props or {}
	local stations = props.stations or {}
	local current_station = props.current_station or 1
	local line_color = props.line_color or "#1976D2" -- professional blue by default

	if #stations == 0 then
		return { Segment:new({ content = "No stations" }):wrap() }
	end

	-- Ensure current_station is in range
	if current_station < 1 then
		current_station = 1
	elseif current_station > #stations then
		current_station = #stations
	end

	local lines = {}
	local max_name_len = 0

	-- Calculate the maximum station name width
	for _, station in ipairs(stations) do
		if #station > max_name_len then
			max_name_len = #station
		end
	end

	local station_width = math.max(max_name_len + 2, 10) -- minimum 10 characters wide

	-- First line: connected points
	local points_line = {}

	-- Initial vertical line
	table.insert(
		points_line,
		Segment:new({
			content = "│",
			color = { fg = line_color },
		})
	)

	-- Points and horizontal lines
	for i, _ in ipairs(stations) do
		local is_current = i == current_station
		local station_marker = is_current and "●" or "○"

		-- Station point
		table.insert(
			points_line,
			Segment:new({
				content = station_marker,
				color = is_current and { fg = "#FFD700", bg = line_color } or { fg = line_color },
			})
		)

		-- Horizontal line connecting to the next point (except the last one)
		if i < #stations then
			table.insert(
				points_line,
				Segment:new({
					content = string.rep("─", station_width - 1),
					color = { fg = line_color },
				})
			)
		end
	end

	lines[#lines + 1] = BufferLine.new(unpack(points_line))

	-- Second line: station names aligned below the points
	local names_line = {}

	-- Space for the initial vertical line
	table.insert(names_line, Segment:new({ content = " " }))

	for i, station in ipairs(stations) do
		local is_current = i == current_station
		local station_name = station

		-- Ensure the name has the correct width
		if #station_name < station_width - 1 then
			station_name = station_name .. string.rep(" ", station_width - 1 - #station_name)
		else
			station_name = station_name:sub(1, station_width - 1)
		end

		-- Add the name with the appropriate color
		table.insert(
			names_line,
			Segment:new({
				content = station_name,
				color = is_current and { fg = "#FFFFFF", bg = "#1a1a1a" } or { fg = "#E0E0E0" },
			})
		)

		-- Space between names (except the last one)
		if i < #stations then
			table.insert(names_line, Segment:new({ content = " " }))
		end
	end

	lines[#lines + 1] = BufferLine.new(unpack(names_line))

	return lines
end

local MetroMapComponent = ui.createComponent("MetroMap", MetroMap, {
	stations = "table",
	current_station = "number",
	line_color = "string",
})

--- Component that simulates train movement through stations
--- @param props { stations: string[], line_color?: string, speed?: number }
local function MovingTrain(props)
	props = props or {}
	local stations = props.stations or {}
	local line_color = props.line_color or "#1976D2"
	local speed = props.speed or 2000 -- 2 seconds per station

	if #stations == 0 then
		return { Segment:new({ content = "No stations" }):wrap() }
	end

	local current_station, setCurrentStation = useState(1)

	-- Move the train to the next station every 'speed' milliseconds
	useInterval(function()
		setCurrentStation(function(current)
			return (current % #stations) + 1
		end)
	end, speed)

	return MetroMapComponent({
		stations = stations,
		current_station = current_station,
		line_color = line_color,
	})
end

local MovingTrainComponent = ui.createComponent("MovingTrain", MovingTrain, {
	stations = "table",
	line_color = "string",
	speed = "number",
})

--- @type ascii-ui.FunctionalComponent
local App = ui.createComponent("App", function()
	return {
		Paragraph({ content = "=== Metro Map ===" }),
		Paragraph({ content = "" }),
		Paragraph({ content = "Line 1:" }),
		MovingTrainComponent({
			stations = {
				"Central",
				"Main Square",
				"University",
				"Park",
				"Airport",
			},
			line_color = "#00C853", -- emerald green (typical metro color)
			speed = 1500,
		}),
		Paragraph({ content = "" }),
		Paragraph({ content = "Line 2:" }),
		MovingTrainComponent({
			stations = {
				"North",
				"Center",
				"South",
			},
			line_color = "#1976D2", -- professional blue
			speed = 2000,
		}),
		Paragraph({ content = "" }),
		Paragraph({ content = "Line 3:" }),
		MovingTrainComponent({
			stations = {
				"East",
				"West",
			},
			line_color = "#D32F2F", -- professional red
			speed = 1800,
		}),
		Paragraph({ content = "" }),
		Paragraph({ content = "Line 4:" }),
		MovingTrainComponent({
			stations = {
				"Terminal A",
				"Terminal B",
				"Terminal C",
			},
			line_color = "#F57C00", -- orange
			speed = 1700,
		}),
	}
end)

ui.mount(App)
