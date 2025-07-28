--- ascii-ui.hooks.useState() *ascii-ui.hooks.useState()*

local fiber = require("ascii-ui.fiber")

local _ref = {}

---
--- Provides local state management within a component.
--- Returns getter and setter functions for a value, triggering UI updates on change.
---
--- Example:
--- ```
--- local function MyComponent()
---   local count, setCount = useState(0)
---     return ui.layout.Column(
---       ui.components.Paragraph({ content = function() return ("Count: %d"):format(count()) end }),
---       ui.components.Button({
---         label = "Increment",
---         on_press = function() setCount(count() + 1) end
---       })
---     )
--- end
--- ```
---
--- @generic T
--- @param initial T The initial state value.
--- @return  { current: T, set: fun(value: T) } wrapper A deep copy of the current state value.
local useRef = function(initial)
	local value = fiber.useState(initial, true)
	local id = fiber.useState(tostring({}))

	if not _ref[id] then
		_ref[id] = { current = value }
	end

	return _ref[id]
end

return useRef
