local Component = require("ascii-ui.components.component")

---@alias ascii-ui.OptionsOpts { options: string[] }

---@class ascii-ui.Options : ascii-ui.Component
---@field options string[]
---@field _index_selected integer
local Options = {}

---@param opts ascii-ui.OptionsOpts
---@return ascii-ui.Options
function Options:new(opts)
	local state = {
		options = opts.options,
		_index_selected = 1,
	}
	return Component:extend(self, state)
end

---@param index integer
---@return string selected_option
function Options:select_index(index)
	self._index_selected = index
	return self.options[self._index_selected]
end

---@return string selected_option
function Options:select_next()
	if #self.options == self._index_selected then
		self._index_selected = 1
	else
		self._index_selected = self._index_selected + 1
	end
	return self.options[self._index_selected]
end

return Options
