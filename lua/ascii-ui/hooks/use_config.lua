--- ascii-ui.hooks.useUserConfig() *ascii-ui.hooks.useUserConfig()*

local useState = require("ascii-ui.hooks.use_state")
local userConfig = require("ascii-ui.config.user_config")

---
--- Provides access to the current user configuration for ascii-ui.
--- This hook returns a deep copy of the user's configuration table,
--- allowing components to read configuration values without risk of
--- mutating the global config.
---
--- @return ascii-ui.Config config A deep copy of the current user configuration.
local useConfig = function()
	local config = useState(userConfig.get())
	return config
end

return useConfig
