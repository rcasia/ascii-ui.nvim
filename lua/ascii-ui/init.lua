local Bufferline = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.segment")
local logger = require("ascii-ui.logger")
local mount = require("ascii-ui.mount")
local user_config = require("ascii-ui.config.user_config")

--- @class ascii-ui.AsciiUI
local AsciiUI = {
	--- This contains all the components available in the library
	components = require("ascii-ui.components"),
	blocks = {
		Bufferline = Bufferline.new,
		---@param opts ascii-ui.SegmentOpts
		Segment = function(opts)
			return Segment:new(opts)
		end,
	},
	createComponent = require("ascii-ui.components.create-component"),
	hooks = require("ascii-ui.hooks"),
	--- This contains the layout class
	layout = require("ascii-ui.layout"),
	mount = mount,
	--- Window factories for different window types
	window = {
		--- Creates a centered floating window (default)
		floating = require("ascii-ui.window.floating"),
		--- Creates a split window (left, right, top, or bottom)
		split = require("ascii-ui.window.split"),
		--- Creates a fullscreen window
		fullscreen = require("ascii-ui.window.fullscreen"),
		--- Wraps an existing user-provided buffer
		buffer = require("ascii-ui.window.buffer"),
	},

	--- @generic T, U
	--- @param items T[]
	--- @param render_fn fun(item: T, i: integer): U
	--- @return U[]
	map = function(items, render_fn)
		return vim.iter(ipairs(items))
			:map(function(i, item)
				return render_fn(item, i)
			end)
			:totable()
	end,
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
