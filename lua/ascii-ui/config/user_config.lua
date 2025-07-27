local logger = require("ascii-ui.logger")

local DEFAULT_CONFIG = require("ascii-ui.config")

--- @type ascii-ui.Config?
local _config = DEFAULT_CONFIG

return {
	set = function(new_config)
		logger.debug("Setting user config %s", vim.inspect(new_config))
		if type(new_config) ~= "table" then
			error("UserConfig must be a table")
		end
		-- merge default config with user config
		_config = vim.tbl_deep_extend("force", DEFAULT_CONFIG, new_config)
	end,
	get = function()
		return _config
	end,
}
