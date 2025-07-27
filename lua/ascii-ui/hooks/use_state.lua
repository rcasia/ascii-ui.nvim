--- ascii-ui.hooks.useState() *ascii-ui.hooks.useState()*

local fiber = require("ascii-ui.fiber")

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
--- @return T value A deep copy of the current state value.
--- @return fun(value: T | fun(value: T): T) setValue Sets the state to a new value and triggers a state change event.
local useState = function(value)
	return fiber.useState(value)
end

return useState
