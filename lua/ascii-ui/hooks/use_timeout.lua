local fiber = require("ascii-ui.fiber")
local useEffect = require("ascii-ui.hooks.use_effect")

---
--- Executes a callback function after a specified delay.
--- The callback always has access to the latest closure values.
--- The timer restarts on every re-render, ensuring the callback fires
--- after the most recent state change.
---
--- @param callback function The function to be executed after the delay.
--- @param delay number|nil The delay in milliseconds. If nil or negative, the timeout is not set.
local function useTimeout(callback, delay)
	local currentFiber = assert(fiber.getCurrentFiber(), "cannot call useTimeout out of the component scope")

	-- Store callback ref on the fiber to persist across renders
	-- This prevents stale closure issues where the callback captures old state
	if not currentFiber._timeoutCallbackRef then
		currentFiber._timeoutCallbackRef = {}
	end
	currentFiber._timeoutCallbackRef.current = callback

	-- Use nil dependencies so effect runs on every render
	-- This ensures the timer restarts with the latest callback
	useEffect(function()
		if delay == nil or delay < 0 then
			return -- Do nothing if delay is nil or negative
		end

		-- Cancel any existing timer
		if currentFiber._timeoutTimer then
			currentFiber._timeoutTimer:stop()
			currentFiber._timeoutTimer:close()
			currentFiber._timeoutTimer = nil
		end

		local timer = assert(vim.uv.new_timer())
		currentFiber._timeoutTimer = timer

		timer:start(
			delay,
			0,
			vim.schedule_wrap(function()
				-- Always call the latest callback via the ref
				if currentFiber._timeoutCallbackRef then
					currentFiber._timeoutCallbackRef.current()
				end
			end)
		)

		return function()
			if currentFiber._timeoutTimer then
				currentFiber._timeoutTimer:stop()
				currentFiber._timeoutTimer:close()
				currentFiber._timeoutTimer = nil
			end
		end
	end, nil) -- nil dependencies = run on every render
end

return useTimeout
