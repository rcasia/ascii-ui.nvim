--- @class ascii-ui.Hooks
local Hooks = {
	useState = require("ascii-ui.hooks.use_state"),
	useEffect = require("ascii-ui.hooks.use_effect"),
	useReducer = require("ascii-ui.hooks.use_reducer"),
	useFunctionRegistry = require("ascii-ui.hooks.use_function_registry"),
	useConfig = require("ascii-ui.hooks.use_config"),
	useInterval = require("ascii-ui.hooks.use_interval"),
	useTimeout = require("ascii-ui.hooks.use_timeout"),
}

return Hooks
