local useEffect = require("ascii-ui.hooks.use_effect")

---
--- Executes a callback function after a specified delay.
---
--- @param callback function The function to be executed after the delay.
--- @param delay number|nil The delay in milliseconds. If nil or negative, the timeout is not set.
local function useTimeout(callback, delay)
	local timer_ref = {}

	useEffect(function()
		if delay == nil or delay < 0 then
			return -- Do nothing if delay is nil or negative
		end

		local timer = assert(vim.uv.new_timer())
		timer_ref.current = timer

		timer:start(delay, 0, vim.schedule_wrap(callback))

		return function()
			if timer_ref.current then
				timer_ref.current:stop()
				timer_ref.current:close()
				timer_ref.current = nil
			end
		end
	end, { delay })
end

return useTimeout
