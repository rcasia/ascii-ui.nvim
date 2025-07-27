--- ascii-ui.hooks.useFunctionRegistry() *ascii-ui.hooks.useFunctionRegistry()*

_G.ascii_ui_function_registry = _G.ascii_ui_function_registry or {}

--- Registers a Lua function and returns a string key reference to be used in ascii-ui component markup or as an indirect callback.
--- This allows the UI runtime to invoke the function later.
---
--- Example:
--- ```
--- local function MyComponent()
---   local ref = ui.hooks.useFunctionRegistry(function()
---     print("Button pressed!")
---   end)
---   return function()
---     return ui.components.Button({ label = "Click Me", on_press = ref })
---   end
--- end
--- ```
---
--- @param fn function The Lua function to register in the global registry.
--- @return string reference String key that can be used to retrieve and call the function.
local useFunctionRegistry = function(fn)
	local key = tostring(fn)
	-- vim.g.ascii_ui_function_registry[fn] = vim.g.ascii_ui_function_registry[fn] or {}
	_G.ascii_ui_function_registry[key] = fn
	return key
end

return useFunctionRegistry
