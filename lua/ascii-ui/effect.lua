--- @class ascii-ui.EffectOpts
--- @field fn fun(): function | nil

--- @alias ascii-ui.EffectStatus "INITIAL" | "MOUNTED" | "CLEANED_UP" | "DONE"

--- @class ascii-ui.Effect
--- @field run fun(): function | nil
--- @field cleanup fun(): nil
--- @field get_status fun(): ascii-ui.EffectStatus

--- @param opts ascii-ui.EffectOpts
--- @return ascii-ui.Effect
local Effect = function(opts)
	local cleanup_fn = nil
	local get_cleanup_fn = function()
		return cleanup_fn
	end

	local status = "INITIAL"
	--- @return "INITIAL" | "MOUNTED" | "CLEANED_UP"
	local get_status = function()
		return status
	end

	return {
		get_status = get_status,
		run = function()
			assert(get_status() == "INITIAL", "Effect can only be run if it is in INITIAL state")
			cleanup_fn = opts.fn()
			status = "MOUNTED"
			return cleanup_fn
		end,
		cleanup = function()
			assert(get_status() == "MOUNTED", "Effect can only be cleaned up if it is MOUNTED")
			local fn = get_cleanup_fn()
			if fn then
				fn()
			end
			status = "CLEANED_UP"
		end,
	}
end

return Effect
