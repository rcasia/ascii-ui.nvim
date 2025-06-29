--- ascii-ui.hooks.useReducer() *ascii-ui.hooks.useReducer()*

local logger = require("ascii-ui.logger")
local useState = require("ascii-ui.hooks.use_state")

--- @alias ascii-ui.ReducerAction {type: string, params: any}

---
--- Manages complex state logic by applying a reducer function to the current state and dispatched actions within an ascii-ui component.
--- Returns getter and dispatch functions for the state.
---
--- Example:
--- ```
--- local function reducer(state, action)
---   if action.type == "increment" then
---     return state + 1
---   end
---   return state
--- end
---
--- local function MyComponent()
---   local count, dispatch = ascii-ui.hooks.useReducer(reducer, 0)
---   return function()
---     return ui.components.Button({
---       label = "Count: " .. count(),
---       on_press = function() dispatch({type="increment"}) end
---     })
---   end
--- end
--- ```
---
--- @generic T
--- @param reducer fun(value: T, action: ascii-ui.ReducerAction): T The reducer function to compute new state.
--- @param value T The initial state value.
--- @return fun(): T getValue Returns the current state value when called.
--- @return fun(action: ascii-ui.ReducerAction) dispatch Dispatches an action to update the state.
local useReducer = function(reducer, value)
	logger.debug("useReducer created")
	local state, setState = useState(value)

	return state, function(action)
		local new_state = reducer(state(), action)
		setState(new_state)
	end
end

return useReducer
