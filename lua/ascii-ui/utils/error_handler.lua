--- Error handling utilities for ascii-ui.
--- Provides consistent error formatting and display for render failures.
---
--- @module "ascii-ui.utils.error_handler"

--- @alias ascii-ui.ErrorType
--- | "render"      # Error during component render
--- | "hook"        # Error in a hook (useState, useEffect, etc.)
--- | "effect"      # Error in an effect or cleanup
--- | "interaction" # Error in user interaction handler
--- | "viewport"    # Error in viewport operations

--- @class ascii-ui.Error
--- @field err_type ascii-ui.ErrorType
--- @field component_path string
--- @field message string

local error_handler = {}

--- Hints for each error type to help users understand what went wrong.
--- @type table<ascii-ui.ErrorType, string>
local HINTS = {
	render = "Components must return a list (table) of FiberNode or BufferLine objects.\n"
		.. "      Did you forget to wrap your return value?\n"
		.. "      \n"
		.. "      Example:\n"
		.. '        return { Segment:new({ content = "hello" }):wrap() }',
	hook = "Hooks (useState, useEffect, useReducer) must be called during component render.\n"
		.. "      They cannot be called inside callbacks, effects, or conditionally.\n"
		.. "      \n"
		.. "      Rules:\n"
		.. "        - Only call hooks at the top level of your component\n"
		.. "        - Don't call hooks inside loops, conditions, or nested functions",
	effect = "Effects run after render and should not throw errors.\n"
		.. "      Check your useEffect cleanup functions and effect logic.\n"
		.. "      \n"
		.. "      Common causes:\n"
		.. "        - Accessing nil values\n"
		.. "        - Calling APIs that don't exist\n"
		.. "        - Cleanup function errors",
	interaction = "User interaction handlers (on_press, on_select, etc.) should not throw.\n"
		.. "      Add error handling to your callbacks.\n"
		.. "      \n"
		.. "      Example:\n"
		.. "        on_press = function()\n"
		.. "          local ok, err = pcall(function() ... end)\n"
		.. "          if not ok then log(err) end\n"
		.. "        end",
	viewport = "Viewport operations (open, update, close) failed.\n"
		.. "      This may be a Neovim API issue or invalid window state.\n"
		.. "      \n"
		.. "      Check:\n"
		.. "        - Window/buffer validity\n"
		.. "        - Neovim API permissions\n"
		.. "        - Floating window configuration",
}

--- Formats an error with consistent structure.
--- @param err_type ascii-ui.ErrorType
--- @param component_path string | nil
--- @param message string
--- @return string formatted_error
function error_handler.format_error(err_type, component_path, message)
	local path = component_path
	if not path or path == "" then
		path = "unknown"
	end
	return string.format("[%s] in <%s>: %s", err_type, path, message)
end

--- Creates an error table with structured information.
--- @param err_type ascii-ui.ErrorType
--- @param component_path string | nil
--- @param message string
--- @return ascii-ui.Error
function error_handler.create_error(err_type, component_path, message)
	return {
		err_type = err_type,
		component_path = component_path or "unknown",
		message = message,
	}
end

--- Gets a helpful hint for an error type.
--- @param err_type ascii-ui.ErrorType
--- @return string hint
function error_handler.get_hint(err_type)
	return HINTS[err_type] or "An unexpected error occurred. Check the component code for issues."
end

--- Converts an error into displayable lines for the viewport.
--- @param err ascii-ui.Error
--- @return string[] lines
function error_handler.render_error_to_lines(err)
	local lines = {}
	local hint = error_handler.get_hint(err.err_type)

	-- Header
	table.insert(lines, "═══ RENDER ERROR ═══")
	table.insert(lines, "")

	-- Error details
	table.insert(lines, "Type: " .. err.err_type)
	table.insert(lines, "Component: " .. err.component_path)
	table.insert(lines, "Message: " .. err.message)
	table.insert(lines, "")

	-- Hint
	table.insert(lines, "Hint: " .. hint)
	table.insert(lines, "")

	-- Footer
	table.insert(lines, "═══════════════════")

	return lines
end

return error_handler
