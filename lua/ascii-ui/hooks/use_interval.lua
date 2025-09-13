local useEffect = require("ascii-ui.hooks.use_effect")

---
--- Executes a callback function at specified intervals.
---
--- @param callback function The function to be executed at each interval.
--- @param delay number|nil The interval delay in milliseconds. If nil, the interval is not set.
local function useInterval(callback, delay)
	local timer_ref = {}

	useEffect(function()
		if delay == nil then
			return
		end

		local timer = assert(vim.uv.new_timer())
		timer_ref.current = timer

		timer:start(delay, delay, vim.schedule_wrap(callback))

		return function()
			if timer_ref.current then
				timer_ref.current:stop()
				timer_ref.current:close()
				timer_ref.current = nil
			end
		end
	end, { delay })
end

return useInterval
