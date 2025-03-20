local Window = require("ascii-ui.window")
local user_interations = require("ascii-ui.user_interactions")

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

local ascii_renderer = require("ascii-ui.renderer"):new(config)

---@param component ascii-ui.Component
---@return integer bufnr
function M.render(component)
	local rendered_buffer = ascii_renderer:render(component)
	-- TODO: should be calculated based on the rendered buffer
	local width = 40
	local height = 10

	local window = Window:new({ width = width, height = height })
	window:open()

	component:subscribe(function(t, key, value)
		window:update(ascii_renderer:render(component):to_lines())
	end)

	window:update(rendered_buffer:to_lines())

	-- bind to user interaction
	user_interations.attach_buffer(rendered_buffer)

	return window.bufnr
end

setmetatable(M, {
	__call = function(_, opts)
		opts = opts or {}
		return M
	end,
})

return M
