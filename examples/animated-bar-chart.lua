local BufferLine = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState
local useInterval = ui.hooks.useInterval

local BAR_COLORS = { "#39d353", "#26a641", "#006d32", "#0e4429", "#161b22" }

local function bar_color(value)
	local idx = math.ceil((1 - value / 100) * #BAR_COLORS)
	return BAR_COLORS[math.max(1, math.min(#BAR_COLORS, idx))]
end

local NUM_BARS = 8
local HEIGHT = 10
local LABELS = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug" }

local App = ui.createComponent("App", function()
	local values, setValues = useState(function()
		local v = {}
		for i = 1, NUM_BARS do
			v[i] = math.random(0, 100)
		end
		return v
	end)

	useInterval(function()
		setValues(function(cur)
			local new = {}
			for i, v in ipairs(cur) do
				local target = math.random(0, 100)
				new[i] = math.max(0, math.min(100, v + (target - v) * 0.1))
			end
			return new
		end)
	end, 200)

	local lines = {}
	for row = HEIGHT, 1, -1 do
		local segs = {}
		for i = 1, NUM_BARS do
			local bar_h = math.ceil((values[i] / 100) * HEIGHT)
			if row <= bar_h then
				segs[#segs + 1] = Segment:new({ content = " " })
				segs[#segs + 1] = Segment:new({ content = " ", color = { bg = bar_color(values[i]) } })
				segs[#segs + 1] = Segment:new({ content = " " })
			else
				segs[#segs + 1] = Segment:new({ content = "   " })
			end
		end
		lines[#lines + 1] = BufferLine.new(unpack(segs))
	end

	local label_segs = {}
	for i = 1, NUM_BARS do
		local lbl = (LABELS[i] or tostring(i)):sub(1, 2)
		if #lbl < 2 then
			lbl = lbl .. " "
		end
		label_segs[#label_segs + 1] = Segment:new({ content = " " })
		label_segs[#label_segs + 1] = Segment:new({ content = lbl, color = { fg = "#8b949e" } })
	end
	lines[#lines + 1] = BufferLine.new(unpack(label_segs))

	local val_segs = {}
	for i = 1, NUM_BARS do
		local v = tostring(math.floor(values[i]))
		if #v == 1 then
			v = " " .. v
		elseif #v > 2 then
			v = v:sub(1, 2)
		end
		val_segs[#val_segs + 1] = Segment:new({ content = " " })
		val_segs[#val_segs + 1] = Segment:new({ content = v, color = { fg = "#E0E0E0" } })
	end
	lines[#lines + 1] = BufferLine.new(unpack(val_segs))

	return {
		Paragraph({ content = "=== Animated Bar Chart ===" }),
		Paragraph({ content = "" }),
		unpack(lines),
	}
end)

ui.mount(App)
