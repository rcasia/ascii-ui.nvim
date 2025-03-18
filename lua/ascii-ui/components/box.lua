local Component = require("ascii-ui.components.component")

---@alias ascii-ui.BoxProps { width: integer, height: integer }

---@class ascii-ui.Box
---@field props ascii-ui.BoxProps
local Box = {
	default_props = { width = 15, height = 3 },
}

---@param props? ascii-ui.BoxProps
---@return ascii-ui.Box
function Box:new(props)
	props = props or {}
	-- default props
	props = vim.tbl_extend("force", self.default_props, props)
	assert(props.height >= 3, "box component failed: height cannot be less than 3")

	return Component:extend(self, {
		_child = "",
		type = "box",
		props = props,
	})
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
