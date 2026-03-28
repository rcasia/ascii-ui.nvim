local Buffer = require("ascii-ui.buffer.buffer")
local Cursor = require("ascii-ui.cursor")
local EventListener = require("ascii-ui.events")
local Window = require("ascii-ui.window")
local i = require("ascii-ui.interaction_type")
local logger = require("ascii-ui.logger")
local user_interations = require("ascii-ui.user_interactions")

local fiber = require("ascii-ui.fiber")
local render = fiber.render
local rerender = fiber.rerender
local is_callable = require("ascii-ui.utils.is_callable")

--- Mounts a root component into a viewport and starts the render loop.
---
--- The simplest call opens a centered Neovim floating window automatically:
--- ```lua
--- local ui = require("ascii-ui")
--- ui.mount(MyComponent)
--- ```
---
--- Pass an explicit viewport to render into a different target.
--- Any object that satisfies the `ascii-ui.Viewport` interface is accepted:
---
--- ```lua
--- -- Built-in: stdout (useful for headless scripts / CI)
--- local ui = require("ascii-ui")
--- local viewport = ui.viewports.StdoutViewport.new()
--- ui.mount(MyComponent, viewport)
--- ```
---
--- ```lua
--- -- Built-in: Neovim floating window with custom dimensions
--- local ui   = require("ascii-ui")
--- local Win  = require("ascii-ui.window")
--- ui.mount(MyComponent, Win.new({ width = 80, height = 24 }))
--- ```
---
--- The viewport lifecycle is:
---   1. `viewport:open()`   — called once, immediately after the first render
---   2. `viewport:update(buffer)` — called on every state-change re-render
---   3. `viewport:close()` — called when the `WinClosed` autocmd fires
---
--- @note When `viewport` is a non-Neovim target (e.g. `StdoutViewport`), the
--- autocmd and `vim.on_key` bindings that are registered below will fire but
--- have no visible effect because `viewport:is_focused()` returns `false` and
--- `viewport:get_id()` / `viewport:get_bufnr()` return `-1`.
---
---@param RootComponent ascii-ui.FunctionalComponent  The root component to render.
---@param viewport? ascii-ui.Viewport  Rendering target. Defaults to a new `ascii-ui.Window`.
---@return integer bufnr  The buffer number used by the viewport (`-1` for non-Neovim targets).
return function(RootComponent, viewport)
	local start = vim.uv.hrtime()
	logger.info("------------------")
	logger.info("Mounting component")
	logger.info("------------------")
	if not is_callable(RootComponent) and RootComponent.__is_a_component then
		error(vim.inspect(RootComponent))
		error("should be a functional component. Found: " .. type(RootComponent))
	end

	-- does first render
	local fiberRoot = render(RootComponent)
	local rendered_buffer = fiberRoot:get_buffer()

	fiber.debugPrint(fiberRoot, logger.debug)

	-- spawns a window (or use the provided viewport)
	local window = viewport or Window.new({ width = rendered_buffer:width(), height = rendered_buffer:height() })
	window:open()

	-- updates the window with the rendered buffer
	window:update(rendered_buffer)

	EventListener:listen("state_change", function()
		local rerender_start = vim.uv.hrtime()
		logger.info("------------------")
		logger.info("Rerendering component")
		logger.info("------------------")

		logger.info("Rerendering on state change for window %d and buffer %d", window:get_id(), window:get_bufnr())
		local current_lines_count = rendered_buffer:height()
		-- rendered_buffer = ascii_renderer:render(Component) -- assign variable to have change the referenced value
		fiberRoot = rerender(fiberRoot)
		fiber.debugPrint(fiberRoot, logger.debug)
		rendered_buffer = fiberRoot:get_buffer()
		local new_lines_count = rendered_buffer:height()
		window:update(rendered_buffer)

		-- rebind the buffer to the window
		user_interations:instance():attach_buffer(rendered_buffer, window:get_bufnr())

		if current_lines_count ~= new_lines_count then
			logger.info("Window %d resized from %d to %d lines", window:get_id(), current_lines_count, new_lines_count)

			-- TODO: this will not work for all cases
			local current_segment = rendered_buffer:find_segment_by_position(Cursor.current_position())
			logger.debug("Current segment: %s", vim.inspect(current_segment))
			if not current_segment or not current_segment:is_focusable() then
				logger.debug("Current segment is not focusable, moving to next focusable segment")
				local position = Cursor.current_position()
				local result = rendered_buffer:find_next_focusable(position)

				logger.debug("next position: %s", vim.inspect(result))
				local next_position = result.pos
				vim.schedule(function()
					Cursor.move_to(next_position, window:get_id())
				end)
			end
		end

		local rerender_elapsed_ns = vim.uv.hrtime() - rerender_start
		logger.info("Rerendering time: %.3f ms", rerender_elapsed_ns / 1e6)
	end)

	-- binds to user interaction
	user_interations:instance():attach_buffer(rendered_buffer, window:get_bufnr())
	logger.info("Attached buffer %s to user interactions", window:get_bufnr())

	local key_map = {
		["l"] = { interaction = i.CURSOR_MOVE_RIGHT, search_fn = Buffer.find_next_focusable },
		["h"] = { interaction = i.CURSOR_MOVE_LEFT, search_fn = Buffer.find_last_focusable },
		["j"] = { interaction = i.CURSOR_MOVE_DOWN, search_fn = Buffer.find_next_focusable },
		["k"] = { interaction = i.CURSOR_MOVE_UP, search_fn = Buffer.find_last_focusable },
	}

	vim.on_key(function(key, _)
		if not window:is_focused() then
			return
		end
		local action = key_map[key]
		if not action then
			return
		end

		local position = Cursor.current_position()

		user_interations:instance():interact({
			buffer_id = window:get_bufnr(),
			position = position,
			interaction_type = action.interaction,
		})

		vim.schedule(function()
			local result = action.search_fn(rendered_buffer, position)
			if result then
				local next_position = result.pos
				Cursor.move_to(next_position, window:get_id(), window:get_bufnr())
				logger.debug(
					"Cursor moved to next focusable position: " .. next_position.line .. ", " .. next_position.col
				)

				local curr = Cursor.current_position()
				assert(
					next_position.line == curr.line and next_position.col == curr.col,
					"Current position is " .. vim.inspect(curr) .. " wanted: " .. vim.inspect(next_position)
				)
			end
		end)
	end, window:get_ns_id())

	local autocommand_id = vim.api.nvim_create_autocmd("CursorMoved", {
		callback = function(args)
			local win_id = tonumber(args.match)

			if win_id ~= window:get_id() then
				return -- not our window
			end

			local segment = rendered_buffer:find_segment_by_position(Cursor.current_position())
			if not segment then
				return
			end

			if segment:is_inputable() then
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

			if win_id ~= window:get_id() then
				return -- not our window
			end
			EventListener:trigger("ui_close")

			-- detach from user interactions
			user_interations:instance():detach_buffer(window:get_bufnr())
			vim.on_key(nil, window:get_ns_id())
			vim.api.nvim_del_autocmd(autocommand_id)
			logger.info("Detached buffer %s from user interactions", window:get_bufnr())

			window:close()
			logger.info("Closed window %d", win_id)
			fiberRoot:unmount()

			EventListener:clear()
		end,
	})

	EventListener:trigger("state_change")
	local elapsed_ns = vim.uv.hrtime() - start
	logger.info("First render time: %.3f ms", elapsed_ns / 1e6)
	return window:get_bufnr()
end
