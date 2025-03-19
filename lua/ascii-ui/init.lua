local Window = require("ascii-ui.window")

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

---@param box ascii-ui.Component
---@return integer bufnr
function M.render(box)
	local window = Window:new({ width = box.props.width, height = box.props.height })
	window:open()

	box:subscribe(function(t, key, value)
		window:update(renderer:render(box))
	end)

	window:update(renderer:render(box))

	return window.bufnr
end

setmetatable(M, {
	__call = function(_, opts)
		opts = opts or {}
		return M
	end,
})

return M
