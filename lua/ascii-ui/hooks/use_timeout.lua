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

	-- Use hookIndex for per-instance storage (like useState)
	local idx = currentFiber.hookIndex

	-- Initialize storage for this timeout instance
	if not currentFiber.hooks[idx] then
		currentFiber.hooks[idx] = {
			callbackRef = {},
			timer = nil,
		}
	end

	local storage = currentFiber.hooks[idx]
	storage.callbackRef.current = callback

	-- Use nil dependencies so effect runs on every render
	-- This ensures the timer restarts with the latest callback
	useEffect(function()
		if delay == nil or delay < 0 then
			return -- Do nothing if delay is nil or negative
		end

		-- Cancel any existing timer
		if storage.timer then
			storage.timer:stop()
			storage.timer:close()
			storage.timer = nil
		end

		local timer = assert(vim.uv.new_timer())
		storage.timer = timer

		timer:start(
			delay,
			0,
			vim.schedule_wrap(function()
				-- Always call the latest callback via the ref
				if storage.callbackRef then
					storage.callbackRef.current()
				end
			end)
		)

		return function()
			if storage.timer then
				storage.timer:stop()
				storage.timer:close()
				storage.timer = nil
			end
		end
	end, nil) -- nil dependencies = run on every render

	currentFiber.hookIndex = idx + 1
end

return useTimeout
