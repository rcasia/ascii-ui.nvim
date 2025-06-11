local Fiber = require("ascii-ui.fiber")

--- @class ascii-ui.Hooks
local Hooks = {
	useState = Fiber.useState,
	useEffect = Fiber.useEffect,
	useReducer = require("ascii-ui.hooks.use_reducer"),
	useFunctionRegistry = require("ascii-ui.hooks.use_function_registry"),
}

return Hooks
