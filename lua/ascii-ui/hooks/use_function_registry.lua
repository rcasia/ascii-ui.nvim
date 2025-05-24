_G.ascii_ui_function_registry = _G.ascii_ui_function_registry or {}

--- @param fn function
--- @return string reference
local useFunctionRegistry = function(fn)
	local key = tostring(fn)
	-- vim.g.ascii_ui_function_registry[fn] = vim.g.ascii_ui_function_registry[fn] or {}
	_G.ascii_ui_function_registry[key] = fn
	return key
end

return useFunctionRegistry
