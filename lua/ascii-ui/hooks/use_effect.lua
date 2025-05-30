--- ascii-ui.hooks.useEffect() *ascii-ui.hooks.useEffect()*

local EventListener = require("ascii-ui.events")

---
--- Runs a side-effect function after component render and when specified observed values change, inside an ascii-ui component.
---
--- Example (runs effect on every render):
--- ```
--- local function MyComponent()
---   local count, setCount = ui.hooks.useState(0)
---   ui.hooks.useEffect(function()
---     print("Rendered!")
---   end)
---   -- component render logic ...
--- end
--- ```
---
--- Example (runs effect only when count changes):
--- ```
--- local function MyComponent()
---   local count, setCount = ui.hooks.useState(0)
---   ui.hooks.useEffect(function()
---     print("Count changed to", count())
---   end, { count })
---   -- component render logic ...
--- end
--- ```
---
--- @param fn function The callback to run as a side effect.
--- @param observed_values? function[] Optional table of state getter functions to observe. If provided, the effect re-runs only when any observed value changes.
local useEffect = function(fn, observed_values)
	local clean_up_fn = fn()

	EventListener:listen("ui_close", function()
		if type(clean_up_fn) == "function" then
			clean_up_fn()
		end
	end)

	if not observed_values then
		return
	end

	local last_seen_values = vim.iter(observed_values)
		:map(function(observed_value)
			return observed_value()
		end)
		:totable()

	EventListener:listen("state_change", function()
		local current_seen_values = vim.iter(observed_values)
			:map(function(observed_value)
				return observed_value()
			end)
			:totable()

		local has_changes = not vim.deep_equal(last_seen_values, current_seen_values)
		if has_changes then
			clean_up_fn = fn()
			if type(clean_up_fn) == "function" then
				clean_up_fn()
			end
		end
	end)
end

return useEffect
