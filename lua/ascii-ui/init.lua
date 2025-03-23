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
function M.mount(component)
	-- does first render
	local rendered_buffer = ascii_renderer:render(component)

	-- spawns a window
	local window = Window:new({ width = rendered_buffer:width(), height = rendered_buffer:height() })
	window:open()

	-- updates the window with the rendered buffer
	window:update(rendered_buffer)

	-- subsequent renders triggered by data changes on component
	component:subscribe(function(t, key, value)
		window:update(ascii_renderer:render(component))
	end)

	-- binds to user interaction
	user_interations:instance():attach_buffer(rendered_buffer, window.bufnr)

	-- binds to window close event
	vim.api.nvim_create_autocmd("WinClosed", {
		callback = function(args)
			local win_id = tonumber(args.match)

			if win_id ~= window.winid then
				return -- not our window
			end

			-- detach from user interactions
			user_interations:instance():detach_buffer(window.bufnr)

			-- destroy our component
			component:destroy()
		end,
	})

	return window.bufnr
end

setmetatable(M, {
	__call = function(_, opts)
		opts = opts or {}
		return M
	end,
})

return M
