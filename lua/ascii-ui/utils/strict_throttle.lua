
local function strict_throttle(fn, delay)
	local running = false
	local queued_args = nil

	local function run(...)
		running = true
		fn(...)
		vim.defer_fn(function()
			if queued_args then
				local args = queued_args
				queued_args = nil
				run(unpack(args)) -- <-- reinicia delay aquí
			else
				running = false
			end
		end, delay)
	end

	return function(...)
		local args = { ... }
		if not running then
			run(unpack(args))
		else
			queued_args = args
		end
	end
end

return strict_throttle
