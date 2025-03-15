---@class one-ui.Box
local Box = {}

function Box:new()
	local state = {
		_children = {},
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@param child string
function Box:add_child(child)
	self._children[#self._children + 1] = child
end

---@return table<any>
function Box:children()
	return self._children
end

return Box
