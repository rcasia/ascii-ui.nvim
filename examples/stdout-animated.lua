local Bufferline = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local ui = require("ascii-ui")
local useState = ui.hooks.useState
local useInterval = ui.hooks.useInterval
local StdoutViewport = ui.viewports.StdoutViewport

local WIDTH = 40
local HEIGHT = 16

local App = ui.createComponent("App", function()
	local x, setX = useState(1)
	local y, setY = useState(1)
	local dx, setDx = useState(1)
	local dy, setDy = useState(1)

	useInterval(function()
		setX(function(cx)
			local nx = cx + dx
			if nx < 1 then
				nx = 1
				setDx(1)
			elseif nx > WIDTH then
				nx = WIDTH
				setDx(-1)
			end
			return nx
		end)
		setY(function(cy)
			local ny = cy + dy
			if ny < 1 then
				ny = 1
				setDy(1)
			elseif ny > HEIGHT then
				ny = HEIGHT
				setDy(-1)
			end
			return ny
		end)
	end, 50)

	local border = "+" .. ("-"):rep(WIDTH) .. "+"
	local lines = { Bufferline.new(Segment:new({ content = border })) }

	for row = 1, HEIGHT do
		local content = ""
		for col = 1, WIDTH do
			content = content .. (row == y and col == x and "O" or " ")
		end
		lines[#lines + 1] = Bufferline.new(Segment:new({ content = "|" .. content .. "|" }))
	end

	lines[#lines + 1] = Bufferline.new(Segment:new({ content = border }))
	return lines
end)

ui.mount(App, StdoutViewport.new())
