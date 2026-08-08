--- A unified color representation for ascii-ui segments.
---
--- `Color` encapsulates foreground and background colors and provides methods
--- to convert them to Neovim highlight groups (with caching) or ANSI truecolor
--- escape sequences for terminal output.
---
--- ```lua
--- local ui = require("ascii-ui")
---
--- -- Table form (both fg and bg optional)
--- local red_on_white = ui.Color.new({ fg = "#ff0000", bg = "#ffffff" })
---
--- -- String shorthand (treated as foreground only)
--- local red = ui.Color.new("#ff0000")
---
--- -- Use with segments
--- local segment = ui.blocks.Segment({ content = "hello", color = red })
--- -- or with string shorthand:
--- local segment2 = ui.blocks.Segment({ content = "hello", color = "#ff0000" })
--- ```
---@class ascii-ui.Color
---@field fg? string foreground color in "#rrggbb" format
---@field bg? string background color in "#rrggbb" format
local Color = {}
Color.__index = Color

--- Module-level cache for highlight groups, keyed by "fg_bg" string.
---@type table<string, string>
local hl_group_cache = {}

--- Module-level cache for Color instances, keyed by "fg_bg" string.
---@type table<string, ascii-ui.Color>
local color_cache = {}

--- Normalize a hex color string to lowercase "#rrggbb" format.
--- Accepts "#rgb", "#rrggbb", "rgb", "rrggbb".
---@param hex string
---@return string normalized "#rrggbb" or nil if invalid
local function normalize_hex(hex)
	if type(hex) ~= "string" then
		return nil
	end
	-- Strip leading #
	local clean = hex:gsub("^#", "")
	-- Expand 3-char hex to 6-char
	if #clean == 3 then
		clean = clean:sub(1, 1):rep(2) .. clean:sub(2, 2):rep(2) .. clean:sub(3, 3):rep(2)
	end
	-- Validate 6-char hex
	if #clean ~= 6 or not clean:match("^[0-9a-fA-F]+$") then
		return nil
	end
	return "#" .. clean:lower()
end

--- Create a cache key from fg and bg.
---@param fg? string
---@param bg? string
---@return string
local function make_key(fg, bg)
	return (fg or "NONE") .. "_" .. (bg or "NONE")
end

--- Creates a new Color instance.
---
--- Accepts either:
---   - A table `{ fg = "#rrggbb", bg = "#rrggbb" }` (both fields optional)
---   - A string `"#rrggbb"` (treated as `{ fg = "#rrggbb" }`)
---
--- Identical colors are cached and return the same instance.
---@param opts string | { fg?: string, bg?: string }
---@return ascii-ui.Color
function Color.new(opts)
	local fg, bg

	if type(opts) == "string" then
		fg = normalize_hex(opts)
		bg = nil
	elseif type(opts) == "table" then
		-- If it's already a Color instance, return it
		if getmetatable(opts) == Color then
			return opts
		end
		fg = normalize_hex(opts.fg)
		bg = normalize_hex(opts.bg)
	else
		error("Color.new expects a string or table, got " .. type(opts))
	end

	local key = make_key(fg, bg)

	if color_cache[key] then
		return color_cache[key]
	end

	local state = { fg = fg, bg = bg }
	setmetatable(state, Color)
	color_cache[key] = state
	return state
end

--- Returns a Neovim highlight group name for this color.
--- Creates the group on first call and caches it for subsequent calls.
---@return string highlight_group_name
function Color:to_hl_group()
	local key = make_key(self.fg, self.bg)

	if hl_group_cache[key] then
		return hl_group_cache[key]
	end

	local group_name = ("AsciiUI_fg%s_bg%s"):format(self.fg or "NONE", self.bg or "NONE"):gsub("#", "")

	vim.api.nvim_set_hl(0, group_name, { fg = self.fg, bg = self.bg })
	hl_group_cache[key] = group_name
	return group_name
end

--- Returns ANSI truecolor escape sequences for this color.
--- Produces foreground (`ESC[38;2;r;g;bm`) and/or background (`ESC[48;2;r;g;bm`)
--- codes as appropriate. Returns empty string if neither fg nor bg is set.
---@return string ansi_escape
function Color:to_ansi()
	local ESC = "\027"
	local ANSI_SGR_FMT = ESC .. "[%d;2;%d;%d;%dm"
	local SGR_FG = 38
	local SGR_BG = 48

	local parts = {}

	if self.fg then
		local r = tonumber(self.fg:sub(2, 3), 16)
		local g = tonumber(self.fg:sub(4, 5), 16)
		local b = tonumber(self.fg:sub(6, 7), 16)
		table.insert(parts, ANSI_SGR_FMT:format(SGR_FG, r, g, b))
	end

	if self.bg then
		local r = tonumber(self.bg:sub(2, 3), 16)
		local g = tonumber(self.bg:sub(4, 5), 16)
		local b = tonumber(self.bg:sub(6, 7), 16)
		table.insert(parts, ANSI_SGR_FMT:format(SGR_BG, r, g, b))
	end

	return table.concat(parts)
end

--- Returns true if neither fg nor bg is set.
---@return boolean
function Color:is_empty()
	return self.fg == nil and self.bg == nil
end

--- Check if an object is a Color instance.
---@param obj any
---@return boolean
function Color.is_color(obj)
	return type(obj) == "table" and obj.__index == Color.__index
end

return Color
