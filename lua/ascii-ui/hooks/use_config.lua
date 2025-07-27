--- ascii-ui.hooks.useUserConfig() *ascii-ui.hooks.useUserConfig()*

local useState = require("ascii-ui.hooks.use_state")

---
--- Provides access to the current user configuration for ascii-ui.
--- This hook returns a deep copy of the user's configuration table,
--- allowing components to read configuration values without risk of
--- mutating the global config.
---
--- @return ascii-ui.Config config A deep copy of the current user configuration.
local useConfig = function()
	-- TODO: get the actual user config
	local config = useState(require("ascii-ui.config"))
	return config
end

return useConfig
