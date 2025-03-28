local Window = require("ascii-ui.window")
local user_interations = require("ascii-ui.user_interactions")
local interaction_type = require("ascii-ui.interaction_type")

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

	-- initialize keymaps
	vim.keymap.set("n", "q", function()
		window:close()
	end, { buffer = window.bufnr, noremap = true, silent = true })

	vim.keymap.set("n", "<CR>", function()
		local bufnr = vim.api.nvim_get_current_buf()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local position = { line = cursor[1], col = cursor[2] }

		user_interations
			:instance()
			:interact({ buffer_id = bufnr, position = position, interaction_type = interaction_type.SELECT })
	end, { buffer = window.bufnr, noremap = true, silent = true })

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

			window:close()
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
