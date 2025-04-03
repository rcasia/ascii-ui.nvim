local Component = require("ascii-ui.components.component")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local highlights = require("ascii-ui.highlights")
local interation_type = require("ascii-ui.interaction_type")

---@alias ascii-ui.OptionsOpts { options: string[], title?: string }

---@class ascii-ui.Options.Item
---@field id integer
---@field name string

---@param option_names string[]
---@return ascii-ui.Options.Item[]
local function from(option_names)
	local id = 0
	local next_id = function()
		id = id + 1
		return id
	end
	return vim.iter(option_names)
		:map(function(name)
			---@type ascii-ui.Options.Item
			return { id = next_id(), name = name }
		end)
		:totable()
end

---@class ascii-ui.Options : ascii-ui.Component
---@field options ascii-ui.Options.Item[]
---@field _index_selected integer
---@field title string
local Options = {
	__name = "OptionsComponent",
}

---@param opts ascii-ui.OptionsOpts
---@return ascii-ui.Options
function Options:new(opts)
	local state = {
		title = opts.title or "",
		options = from(opts.options),
		_index_selected = 1,
	}
	return Component:extend(self, state)
end

---@return string selected_option
function Options:selected()
	return self.options[self._index_selected].name
end

---@param index integer
---@return string selected_option
function Options:select_index(index)
	self._index_selected = index
	return self.options[self._index_selected].name
end

---@return string selected_option
function Options:select_next()
	if #self.options == self._index_selected then
		self._index_selected = 1
	else
		self._index_selected = self._index_selected + 1
	end
	return self.options[self._index_selected].name
end

---@return ascii-ui.BufferLine[]
function Options:render()
	local selected_id = self.options[self._index_selected].id

	local bufferlines = vim.iter(self.options)
		:map(function(option)
			local content = ""
			local highlight

			if option.id == selected_id then
				content = ("[x] %s"):format(option.name)
				highlight = highlights.SELECTION
			else
				content = ("[ ] %s"):format(option.name)
			end

			return Element:new(content, true, {
				[interation_type.SELECT] = function()
					self:select_index(option.id)
				end,
			}, highlight)
		end)
		:map(function(element)
			return Bufferline:new(element)
		end)
		:totable()

	if vim.fn.empty(self.title) == 0 then
		table.insert(bufferlines, 1, Bufferline:new(Element:new(self.title)))
	end
	return bufferlines
end

return Options
