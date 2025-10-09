--- ascii-ui.hooks.useEffect() *ascii-ui.hooks.useEffect()*

local fiber = require("ascii-ui.fiber")
local logger = require("ascii-ui.logger")

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
	logger.debug(
		"running useEffect with deps: "
			.. vim.inspect(dependencies)
			.. " vs prev: "
			.. vim.inspect(currentFiber.prevDeps[currentFiber.effectIndex])
	)

	local idx = currentFiber.effectIndex
	local prev = currentFiber.prevDeps[idx]
	local shouldRun = false

	if dependencies == nil then
		-- Sin array de deps: ejecutar en cada render y rerender
		shouldRun = true
	elseif #dependencies == 0 then
		-- Array vacío: sólo montaje
		shouldRun = (prev == nil)
	else
		if not prev then
			shouldRun = true
		else
			-- Shallow compare
			if #dependencies ~= #prev then
				shouldRun = true
			else
				for i = 1, #dependencies do
					if dependencies[i] ~= prev[i] then
						shouldRun = true
						break
					end
				end
			end
		end
	end

	logger.debug("shouldRun: " .. tostring(shouldRun))

	if shouldRun then
		local prevCleanup = currentFiber.cleanups[idx]

		local effect_type = dependencies and "ONCE" or "REPEATING"
		if effect_type == "ONCE" then
			if prevCleanup then
				currentFiber:add_cleanup(prevCleanup)
			end
			currentFiber:add_effect(function()
				local newCleanup = fn()
				currentFiber.cleanups[idx] = type(newCleanup) == "function" and newCleanup or nil
			end, effect_type)
		else
			currentFiber:add_effect(function()
				if currentFiber.cleanups[idx] then
					currentFiber.cleanups[idx]()
				end
				local newCleanup = fn()
				currentFiber.cleanups[idx] = type(newCleanup) == "function" and newCleanup or nil
			end, effect_type)
		end
	end

	-- guardar dependencias anteriores correctamente
	if dependencies == nil then
		currentFiber.prevDeps[idx] = nil
	elseif #dependencies == 0 then
		currentFiber.prevDeps[idx] = {} -- ← mantiene array vacío
	else
		currentFiber.prevDeps[idx] = { unpack(dependencies) }
	end
	currentFiber.effectIndex = currentFiber.effectIndex + 1
end

return useEffect
