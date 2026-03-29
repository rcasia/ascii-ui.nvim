--- @class ascii-ui.HexaColor
--- @field group string The name of the highlight group created for the hex color
local HexaColor = {}
HexaColor.__index = HexaColor

--- Tracks highlight groups that have already been registered in the current session.
--- Avoids calling nvim_set_hl on every HexaColor.new() call for the same color.
--- @type table<string, boolean>
local registered = {}

--- Create a new instance and register the highlight group
--- @param hex  string a hex color code (e.g. "#ff00aa")
--- @return ascii-ui.HexaColor instance with its highlight group name
function HexaColor.new(hex)
	local clean = hex:gsub("#", ""):lower()
	local group = "HexColor_" .. clean
	if not registered[group] then
		vim.api.nvim_set_hl(0, group, { fg = "#" .. clean })
		registered[group] = true
	end
	return setmetatable({ group = group }, HexaColor)
end

--- Retrieve the highlight group name
--- @return string highlight the name of the highlight group created
function HexaColor:get_highlight()
	return self.group
end

return HexaColor
