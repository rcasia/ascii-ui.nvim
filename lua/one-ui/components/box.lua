---@class one-ui.Box
local Box = {}

---@param props? { width?: number }
function Box:new(props)
	local state = {
		_children = {},
		type = "box",
		props = props or { width = 15 },
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
