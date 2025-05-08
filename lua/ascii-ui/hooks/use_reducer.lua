local EventListener = require("ascii-ui.events")
local useState = require("ascii-ui.hooks.use_state")

--- @generic T
--- @param value T
--- @param reducer fun(value: T, action: string): T
--- @return T getValue
--- @return fun(action: string) dispatch
local useReducer = function(reducer, value)
	local state, setState = useState(value)

	return state, function(action)
		local new_state = reducer(state(), action)
		setState(new_state)
	end
end

return useReducer
