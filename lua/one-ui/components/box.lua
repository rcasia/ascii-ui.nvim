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
		_child = "",
		type = "box",
		props = props,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@param child string
function Box:set_child(child)
	self._child = child
end

---@return string
function Box:child()
	return self._child
end

---@return boolean
function Box:has_child()
	return self._child ~= ""
end

return Box
