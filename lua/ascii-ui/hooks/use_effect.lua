local EventListener = require("ascii-ui.events")

local useEffect = function(fn, observed_values)
	fn()

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
			fn()
		end
	end)
end

return useEffect
