--- @deprecated Use `ascii-ui.color` instead. This module is kept for backward compatibility.
--- @class ascii-ui.HexaColor
--- @field group string The name of the highlight group created for the hex color
local HexaColor = {}
HexaColor.__index = HexaColor

--- Create a new instance and register the highlight group
--- @deprecated Use `require("ascii-ui.color").new(hex):to_hl_group()` instead.
--- @param hex  string a hex color code (e.g. "#ff00aa")
--- @return ascii-ui.HexaColor instance with its highlight group name
function HexaColor.new(hex)
	local Color = require("ascii-ui.color")
	local color = Color.new(hex)
	local group = color:to_hl_group()
	return setmetatable({ group = group }, HexaColor)
end

--- Retrieve the highlight group name
--- @deprecated Use `Color:to_hl_group()` instead.
--- @return string highlight the name of the highlight group created
function HexaColor:get_highlight()
	return self.group
end

return HexaColor
