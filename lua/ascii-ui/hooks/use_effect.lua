--- ascii-ui.hooks.useEffect() *ascii-ui.hooks.useEffect()*

local fiber = require("ascii-ui.fiber")
local logger = require("ascii-ui.logger")

local Effect = require("ascii-ui.effect")

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
	local currentFiber = assert(fiber.getCurrentFiber(), "cannot call useEffect out of the component scope")
	assert(type(dependencies) == "nil" or vim.isarray(dependencies), "deps should be an array or nil")

	logger.debug("running useEffect on %s", currentFiber.type)

	local idx = currentFiber.effectIndex

	local lastEffect = currentFiber.effects[idx]
	local shouldRun, reasons = not lastEffect, { "no last effect on idx: " .. idx }
	if lastEffect then
		shouldRun, reasons = lastEffect.should_be_replaced(dependencies)
	end

	logger.info("whether the effect should run reasons: " .. vim.inspect(reasons))

	local new_effect
	if shouldRun then
		local effect_type = dependencies and "ONCE" or "REPEATING"
		new_effect = Effect({ fn = fn, dependencies = dependencies })
		currentFiber:add_effect(new_effect.run, effect_type)
	end

	if new_effect then
		if lastEffect and lastEffect.cleanup then
			currentFiber:add_cleanup(function()
				lastEffect.cleanup()
			end)
		end
		currentFiber.effects[idx] = new_effect
	end
	currentFiber.prevDeps[idx] = dependencies
	currentFiber.effectIndex = currentFiber.effectIndex + 1
end

return useEffect
