local Component = require("ascii-ui.components.component")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local interaction_type = require("ascii-ui.interaction_type")
local global_config = require("ascii-ui.config")

---@class ascii-ui.Slider : ascii-ui.Component
---@field value integer current value of the slider, from 0 to 100
---@field step integer how much to move the slider by
---@field title? string title of the slider
---@field on_change fun(self: ascii-ui.Slider, f : fun(component: ascii-ui.Slider, key: ascii-ui.Slider.Fields, value: any))
local Slider = {
	__name = "SliderComponent",
}

---@param value? integer | { title: string, value: integer }
---@return ascii-ui.Slider
function Slider:new(value)
	local title = nil
	if type(value) == "table" then
		title = value.title or nil
		value = value.value or 0
	end

	--- @enum (key) ascii-ui.Slider.Fields
	local state = {
		value = value or 0,
		step = 10,
		title = title,
	}

	return Component:extend(self, state)
end

function Slider:move_right()
	if self.value >= 100 - self.step then
		self.value = 100
	else
		self.value = self.value + 10
	end
end

function Slider:move_left()
	if self.value <= self.step then
		self.value = 0
	else
		self.value = self.value - 10
	end
end

---@param value integer
function Slider:slide_to(value)
	self.value = value
end

---@param config ascii-ui.Config
---@return ascii-ui.BufferLine[]
function Slider:render(config)
	config = config or {}
	-- override default config
	config = vim.tbl_extend("force", global_config, config)
	local cc = config.characters

	local interactions = {
		[interaction_type.CURSOR_MOVE_RIGHT] = function()
			self:move_right()
		end,
		[interaction_type.CURSOR_MOVE_LEFT] = function()
			self:move_left()
		end,
	}

	local width = 10
	local knob_position = math.floor(width * self.value / 100)

	return {
		self.title and Bufferline:new(Element:new(self.title, false)),
		Bufferline:new(
			Element:new(cc.horizontal:rep(knob_position), false, interactions),
			Element:new(cc.thumb, true, interactions),
			Element:new(cc.horizontal:rep(width - knob_position), false, interactions),
			Element:new((" %d%%"):format(self.value))
		),
	}
end

return Slider
