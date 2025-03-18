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
---@return integer bufnr
function M.render(box)
	local window = Window:new({ width = box.props.width, height = box.props.height })
	window:open()

	box:subscribe(function(t, key, value)
		-- window:update(renderer:render(box))
		print("cambio en suscription! " .. vim.inspect({ key = key, value = value }))
	end)

	window:update(renderer:render(box))

	setInterval(1000, function()
		local time = os.date("%H:%M:%S") ---@cast time string
		box:set_child(time)
		print("cambio en interval! " .. vim.inspect(box))
	end)

	return window.bufnr
end

setmetatable(M, {
	__call = function(_, opts)
		opts = opts or {}
		return M
	end,
})

return M
