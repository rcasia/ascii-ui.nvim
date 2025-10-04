--- ascii-ui.hooks.useEffect() *ascii-ui.hooks.useEffect()*

local fiber = require("ascii-ui.fiber")

---
--- Runs a side-effect function after component render and when specified observed values change, inside an ascii-ui component.
---
--- Example (runs effect only when count changes):
--- ```
--- local MyComponent = ui.createComponent("MyComponent", function()
---   local count, setCount = ui.hooks.useState(0)
---   ui.hooks.useEffect(function()
---     print("Count changed to" .. count)
---   end, { count })
---   -- component render logic ...
--- end)
--- ```
---
--- @param fn function The callback to run as a side effect.
--- @param dependencies? any[] Optional table of state getter functions to observe. If provided, the effect re-runs only when any observed value changes.
local useEffect = function(fn, dependencies)
	return fiber._useEffect(fn, dependencies)
end

return useEffect
