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
	--- Built-in viewport implementations.
	---
	--- A viewport is any object satisfying the `ascii-ui.Viewport` interface; pass
	--- one as the second argument to `ui.mount` to control where the UI is rendered.
	---
	--- Available viewports:
	---   - `StdoutViewport` — renders to terminal stdout with ANSI truecolor codes.
	---     Useful for headless scripts, animations, or CI pipelines.
	---
	--- Example:
	--- ```lua
	--- local ui = require("ascii-ui")
	--- ui.mount(MyComponent, ui.viewports.StdoutViewport.new())
	--- ```
	viewports = {
		StdoutViewport = require("ascii-ui.viewports.stdout"),
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
