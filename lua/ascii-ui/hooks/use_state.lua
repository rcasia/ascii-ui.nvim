local EventListener = require("ascii-ui.events")

--- @generic T
--- @param value T
--- @return fun(): T getValue
--- @return fun(value: T) setValue
local useState = function(value)
	local _value = value
	local setValue = function(newValue)
		_value = newValue
		EventListener:trigger("state_change")
	end
	local getValue = function()
		return _value
	end

	return getValue, setValue
end

return useState
