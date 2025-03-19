local Component = require("ascii-ui.components.component")

---@alias ascii-ui.SwitchOpts { options: string[] }

---@class ascii-ui.Switch : ascii-ui.Component
---@field options string[]
---@field _index_selected integer
local Switch = {}

---@param opts ascii-ui.SwitchOpts
---@return ascii-ui.Switch
function Switch:new(opts)
	local state = {
		options = opts.options,
		_index_selected = 1,
	}
	return Component:extend(self, state)
end

---@return string selected_option
function Switch:select_next()
	if #self.options == self._index_selected then
		self._index_selected = 1
	else
		self._index_selected = self._index_selected + 1
	end
	return self.options[self._index_selected]
end

return Switch
