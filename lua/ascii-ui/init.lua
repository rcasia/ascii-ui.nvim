local logger = require("ascii-ui.logger")
local mount = require("ascii-ui.mount")
local user_config = require("ascii-ui.config.user_config")

--- @class ascii-ui.AsciiUI
local AsciiUI = {
	--- This contains all the components available in the library
	components = require("ascii-ui.components"),
	createComponent = require("ascii-ui.components.create-component"),
	hooks = require("ascii-ui.hooks"),
	--- This contains the layout class
	layout = require("ascii-ui.layout"),
	mount = mount,
}

function AsciiUI.setup(config)
	config = config or {}
	user_config.set(config)

	logger.set_level(user_config.get().log_level)
	return AsciiUI
end

setmetatable(AsciiUI, {
	__call = function(self, config)
		return self.setup(config)
	end,
})

return AsciiUI
