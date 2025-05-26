--- ascii-ui.hooks.useState() *ascii-ui.hooks.useState()*

local EventListener = require("ascii-ui.events")
local logger = require("ascii-ui.logger")

---
--- Provides local state management within a component.
--- Returns getter and setter functions for a value, triggering UI updates on change.
---
--- Example:
--- ```
--- local function MyComponent()
---   local count, setCount = useState(0)
---   return function()
---     return ui.layout.Column(
---       ui.components.Paragraph({ content = function() return ("Count: %d"):format(count()) end }),
---       ui.components.Button({
---         label = "Increment",
---         on_press = function() setCount(count() + 1) end
---       })
---     )
---   end
--- end
--- ```
---
--- @generic T
--- @param value T The initial state value.
--- @return fun(): T getValue Returns the current state value when called.
--- @return fun(value: T | fun(value: T): T) setValue Sets the state to a new value and triggers a state change event.
local useState = function(value)
	logger.debug("useState created")
	local _value = value
	local setValue = function(newValue)
		if type(newValue) == "function" then
			newValue = newValue(_value)
		end
		_value = newValue
		EventListener:trigger("state_change")
	end
	local getValue = function()
		return _value
	end

	return getValue, setValue
end

return useState
