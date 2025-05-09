local useState = require("ascii-ui.hooks.use_state")

--- @alias ascii-ui.ReducerAction {type: string, params: any }
--- @generic T
--- @param reducer fun(value: T, action: ascii-ui.ReducerAction): T
--- @param value T
--- @return fun(): T getValue
--- @return fun(action: ascii-ui.ReducerAction) dispatch
local useReducer = function(reducer, value)
	local state, setState = useState(value)

	return state, function(action)
		local new_state = reducer(state(), action)
		setState(new_state)
	end
end

return useReducer
