--- @class ascii-ui.EffectOpts
--- @field fn fun(): function
--- @field dependencies any[] | nil

--- @alias ascii-ui.EffectStatus "INITIAL" | "MOUNTED" | "CLEANED_UP" | "DONE"

--- @enum ascii-ui.EffectReplacementReason
local EFFECT_REPLACEMENT_REASON = {
	DIFFERENT_VALUES = "DIFFERENT_VALUES",
	DIFFERENT_COUNT_OF_VALUES = "DIFFERENT_COUNT_OF_VALUES",
	NIL_DEPENDENCIES = "NIL_DEPENDENCIES",
	EMPTY_AND_NOT_RUN = "EMPTY_AND_NOT_RUN",
}

--- @class ascii-ui.Effect
--- @field run fun(): function | nil
--- @field cleanup fun(): nil
--- @field get_status fun(): ascii-ui.EffectStatus
--- @field should_be_replaced fun(new_dependencies?: any[]): boolean, ascii-ui.EffectReplacementReason[]

--- @param opts ascii-ui.EffectOpts
--- @return ascii-ui.Effect
local Effect = function(opts)
	local cleanup_fn = function() end
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
			local current_status = get_status()
			assert(
				current_status == "INITIAL" or current_status == "MOUNTED",
				"Effect can only be run if it is in INITIAL or MOUNTED state. Found: " .. get_status()
			)
			if current_status == "MOUNTED" then
				get_cleanup_fn()()
			end
			cleanup_fn = opts.fn()
			status = "MOUNTED"
			return cleanup_fn
		end,
		cleanup = function()
			assert(get_status() == "MOUNTED", "Effect can only be cleaned up if it is MOUNTED. Found: " .. get_status())
			local fn = get_cleanup_fn()
			if fn then
				fn()
			end
			status = "CLEANED_UP"
		end,
		should_be_replaced = function(new_deps)
			local last_deps = opts.dependencies

			local reasons = {}
			if new_deps == nil then
				reasons[#reasons + 1] = EFFECT_REPLACEMENT_REASON.NIL_DEPENDENCIES
			else
				if not last_deps then
					reasons[#reasons + 1] = EFFECT_REPLACEMENT_REASON.NIL_DEPENDENCIES
					reasons[#reasons + 1] = EFFECT_REPLACEMENT_REASON.DIFFERENT_COUNT_OF_VALUES
				else
					-- Shallow compare
					if #new_deps ~= #last_deps then
						reasons[#reasons + 1] = EFFECT_REPLACEMENT_REASON.DIFFERENT_COUNT_OF_VALUES
					else
						for i = 1, #new_deps do
							if new_deps[i] ~= last_deps[i] then
								reasons[#reasons + 1] = EFFECT_REPLACEMENT_REASON.DIFFERENT_VALUES
								break
							end
						end
					end
				end
			end
			return #reasons > 0, reasons
		end,
		dependencies = opts.dependencies,
	}
end

return Effect
