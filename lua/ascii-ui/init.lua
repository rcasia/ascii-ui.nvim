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
	-- TODO: should be calculated based on the rendered buffer
	local width = 40
	local height = 10

	-- spawns a window
	local window = Window:new({ width = width, height = height })
	window:open()

	-- does first render
	local rendered_buffer = ascii_renderer:render(component)
	window:update(rendered_buffer)

	-- subsequent renders triggered by data changes on component
	component:subscribe(function(t, key, value)
		window:update(ascii_renderer:render(component))
	end)

	-- binds to user interaction
	user_interations:instance():attach_buffer(rendered_buffer)

	return window.bufnr
end

setmetatable(M, {
	__call = function(_, opts)
		opts = opts or {}
		return M
	end,
})

return M
