---@class one-ui.Box
local Box = {
	default_props = { width = 15, height = 3 },
}

---@param props? { width?: number, height?: number }
function Box:new(props)
	props = props or {}
	-- default props
	props = vim.tbl_extend("force", self.default_props, props)
	assert(props.height >= 3, "box component failed: height cannot be less than 3")

	local state = {
		_children = {},
		type = "box",
		props = props,
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
