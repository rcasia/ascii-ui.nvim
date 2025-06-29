--- @class ascii-ui.Hooks
local Hooks = {
	useState = require("ascii-ui.hooks.use_state"),
	useEffect = require("ascii-ui.hooks.use_effect"),
	useReducer = require("ascii-ui.hooks.use_reducer"),
	useFunctionRegistry = require("ascii-ui.hooks.use_function_registry"),
}

return Hooks
