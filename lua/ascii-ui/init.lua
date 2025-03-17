local Window = require("ascii-ui.window")
local uv = vim.uv

local M = {}

local config = {
	characters = {
		top_left = "╭",
		top_right = "╮",
		bottom_left = "╰",
		bottom_right = "╯",
		horizontal = "─",
		vertical = "│",
	},
}

local renderer = require("ascii-ui.renderer"):new(config)

local function setInterval(interval, callback)
	local timer = assert(uv.new_timer())
	timer:start(interval, interval, function()
		callback()
	end)
	return timer
end

---@param box ascii-ui.Box
function M.render(box)
	local window = Window:new({ width = box.props.width, height = box.props.height })
	window:open()

	setInterval(1000, function()
		local time = os.date("%H:%M:%S")
		box:set_child(time)

		window:update(renderer:render(box))
	end)
end

setmetatable(M, {
	__call = function(_, opts)
		opts = opts or {}
		return M
	end,
})

return M
