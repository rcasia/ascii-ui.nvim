--- @class ascii-ui.Hooks
local Hooks = {
	useState = require("ascii-ui.hooks.use_state"),
	useReducer = require("ascii-ui.hooks.use_reducer"),
	useEffect = require("ascii-ui.hooks.use_effect"),
	useFunctionRegistry = require("ascii-ui.hooks.use_function_registry"),
}

return Hooks
