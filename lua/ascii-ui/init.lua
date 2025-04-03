local Window = require("ascii-ui.window")
local user_interations = require("ascii-ui.user_interactions")
local i = require("ascii-ui.interaction_type")
local config = require("ascii-ui.config")
local Layout = require("ascii-ui.layout")
local components = require("ascii-ui.components")

local M = {}

local ascii_renderer = require("ascii-ui.renderer"):new(config)

--- This contains all the components available in the library
M.components = components

--- This contains the layout class
M.layout = Layout

---@param layout ascii-ui.Layout | ascii-ui.Component
---@return integer bufnr
function M.mount(layout)
	-- does first render
	local rendered_buffer = ascii_renderer:render(layout)

	-- spawns a window
	local window = Window:new({ width = rendered_buffer:width(), height = rendered_buffer:height() })
	window:open()

	-- updates the window with the rendered buffer
	window:update(rendered_buffer)

	-- subsequent renders triggered by data changes on component
	layout:on_change(function()
		rendered_buffer = ascii_renderer:render(layout) -- assign variable to have change the referenced value
		window:update(rendered_buffer)
	end)

	-- binds to user interaction
	user_interations:instance():attach_buffer(rendered_buffer, window.bufnr)

	-- initialize keymaps
	vim.keymap.set("n", config.keymaps.quit, function()
		window:close()
	end, { buffer = window.bufnr, noremap = true, silent = true })

	vim.keymap.set("n", config.keymaps.select, function()
		local bufnr = vim.api.nvim_get_current_buf()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local position = { line = cursor[1], col = cursor[2] }

		user_interations:instance():interact({ buffer_id = bufnr, position = position, interaction_type = i.SELECT })
	end, { buffer = window.bufnr, noremap = true, silent = true })

	vim.on_key(function(key, _)
		local bufnr = vim.api.nvim_get_current_buf()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local position = { line = cursor[1], col = cursor[2] }

		local interaction
		if key == "l" then
			interaction = i.CURSOR_MOVE_RIGHT
		end

		if key == "h" then
			interaction = i.CURSOR_MOVE_LEFT
		end

		if key == "j" then
			interaction = i.CURSOR_MOVE_DOWN
		end

		if key == "k" then
			interaction = i.CURSOR_MOVE_UP
		end

		if interaction then
			user_interations:instance():interact({
				buffer_id = bufnr,
				position = position,
				interaction_type = interaction,
			})
		end

		vim.schedule(function()
			if interaction == i.CURSOR_MOVE_RIGHT or interaction == i.CURSOR_MOVE_DOWN then
				local result = rendered_buffer:find_position_of_the_next_focusable({
					line = position.line,
					col = position.col,
				})

				local next_position = result.pos
				vim.api.nvim_win_set_cursor(window.winid, { next_position.line, next_position.col })
			end

			if interaction == i.CURSOR_MOVE_LEFT or interaction == i.CURSOR_MOVE_UP then
				local result = rendered_buffer:find_position_of_the_last_focusable({
					line = position.line,
					col = position.col,
				})

				local next_position = result.pos
				vim.api.nvim_win_set_cursor(window.winid, { next_position.line, next_position.col })
			end
		end)
	end, window.ns_id)
	-- binds to window close event
	vim.api.nvim_create_autocmd("WinClosed", {
		callback = function(args)
			local win_id = tonumber(args.match)

			if win_id ~= window.winid then
				return -- not our window
			end

			-- detach from user interactions
			user_interations:instance():detach_buffer(window.bufnr)
			vim.on_key(nil, window.ns_id)

			-- destroy our component
			layout:destroy()

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
