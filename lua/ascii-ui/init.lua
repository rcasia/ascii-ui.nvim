local Cursor = require("ascii-ui.cursor")
local EventListener = require("ascii-ui.events")
local Window = require("ascii-ui.window")
local config = require("ascii-ui.config")
local i = require("ascii-ui.interaction_type")
local logger = require("ascii-ui.logger")
local user_interations = require("ascii-ui.user_interactions")

local ascii_renderer = require("ascii-ui.renderer"):new(config)

--- @class ascii-ui.AsciiUI
local AsciiUI = {
	--- This contains all the components available in the library
	components = require("ascii-ui.components"),
	createComponent = require("ascii-ui.components.functional-component"),
	hooks = require("ascii-ui.hooks"),
	--- This contains the layout class
	layout = require("ascii-ui.layout"),
}

---@param component ascii-ui.FunctionalComponent
---@return integer bufnr
function AsciiUI.mount(component)
	local start = vim.loop.hrtime()
	logger.info("------------------")
	logger.info("Mounting component")
	logger.info("------------------")
	if type(component) ~= "function" then
		error("should be a functional component")
	end

	-- does first render
	local rendered_buffer = ascii_renderer:render(component)

	-- spawns a window
	local window = Window.new({ width = rendered_buffer:width(), height = rendered_buffer:height() })
	window:open()

	-- updates the window with the rendered buffer
	window:update(rendered_buffer)

	EventListener:listen("state_change", function()
		local rerender_start = vim.loop.hrtime()

		logger.info("Rerendering on state change for window %d and buffer %d", window.winid, window.bufnr)
		local current_lines_count = rendered_buffer:height()
		rendered_buffer = ascii_renderer:render(component) -- assign variable to have change the referenced value
		local new_lines_count = rendered_buffer:height()
		window:update(rendered_buffer)

		-- rebind the buffer to the window
		user_interations:instance():attach_buffer(rendered_buffer, window.bufnr)

		if current_lines_count ~= new_lines_count then
			logger.info("Window %d resized from %d to %d lines", window.winid, current_lines_count, new_lines_count)

			-- TODO: this will not work for all cases
			local current_element = rendered_buffer:find_element_by_position(Cursor.current_position())
			logger.debug("Current element: %s", vim.inspect(current_element))
			if not current_element or not current_element:is_focusable() then
				logger.debug("Current element is not focusable, moving to next focusable element")
				local position = Cursor.current_position()
				local result = rendered_buffer:find_position_of_the_next_focusable(position)

				logger.debug("next position: %s", vim.inspect(result))
				local next_position = result.pos
				vim.schedule(function()
					vim.api.nvim_win_set_cursor(window.winid, { next_position.line, next_position.col })
				end)
			end
		end

		local rerender_elapsed_ns = vim.loop.hrtime() - rerender_start
		logger.info("Rerendering time: %.3f ms", rerender_elapsed_ns / 1e6)
	end)

	-- binds to user interaction
	user_interations:instance():attach_buffer(rendered_buffer, window.bufnr)
	logger.info("Attached buffer %s to user interactions", window.bufnr)

	vim.on_key(function(key, _)
		if not window:is_focused() then
			return
		end

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
					col = position.col + 1, -- next calculated from the next column on same line
				})

				local next_position = result.pos
				vim.api.nvim_win_set_cursor(window.winid, { next_position.line, next_position.col })
				logger.debug(
					"Cursor moved to next focusable position: " .. next_position.line .. ", " .. next_position.col
				)
			end

			if interaction == i.CURSOR_MOVE_LEFT or interaction == i.CURSOR_MOVE_UP then
				local result = rendered_buffer:find_position_of_the_last_focusable({
					line = position.line,
					col = position.col - 1,
				})

				local next_position = result.pos
				vim.api.nvim_win_set_cursor(window.winid, { next_position.line, next_position.col })
				logger.debug(
					"Cursor moved to last focusable position: " .. next_position.line .. ", " .. next_position.col
				)
			end
		end)
	end, window.ns_id)

	local autocommand_id = vim.api.nvim_create_autocmd("CursorMoved", {
		callback = function(args)
			local win_id = tonumber(args.match)

			if win_id ~= window.winid then
				return -- not our window
			end

			local element = rendered_buffer:find_element_by_position(Cursor.current_position())
			if not element then
				return
			end

			if element:is_inputable() then
				window:enable_edits()
			else
				window:disable_edits()
			end
		end,
	})

	-- binds to window close event
	vim.api.nvim_create_autocmd("WinClosed", {
		callback = function(args)
			local win_id = tonumber(args.match)

			if win_id ~= window.winid then
				return -- not our window
			end
			EventListener:trigger("ui_close")

			-- detach from user interactions
			user_interations:instance():detach_buffer(window.bufnr)
			vim.on_key(nil, window.ns_id)
			vim.api.nvim_del_autocmd(autocommand_id)
			logger.info("Detached buffer %s from user interactions", window.bufnr)

			window:close()
			logger.info("Closed window %d", win_id)

			EventListener:clear()
		end,
	})

	local elapsed_ns = vim.loop.hrtime() - start
	logger.info("First render time: %.3f ms", elapsed_ns / 1e6)
	return window.bufnr
end

setmetatable(AsciiUI, {
	__call = function(_, _) -- (self, opts)
		return AsciiUI
	end,
})

return AsciiUI
