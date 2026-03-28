--- Writer function type used by StdoutViewport to emit output.
--- Defaults to `io.write`. Override this in tests or custom environments
--- where you need to capture or redirect the output.
---@alias ascii-ui.StdoutViewport.Writer fun(s: string)

--- A viewport implementation that renders the UI to terminal stdout using
--- ANSI truecolor escape codes.
---
--- `StdoutViewport` implements `ascii-ui.Viewport` and can be passed directly to
--- `ui.mount` as an alternative to the default Neovim floating window. It is useful
--- for headless scripts, CI pipelines, or any context where Neovim's windowing API
--- is not available.
---
--- **Basic usage**
--- ```lua
--- local ui = require("ascii-ui")
---
--- local viewport = ui.viewports.StdoutViewport.new()
--- ui.mount(MyComponent, viewport)
--- ```
---
--- **Custom writer** (e.g. for testing or piping to a file)
--- ```lua
--- local lines = {}
--- local viewport = ui.viewports.StdoutViewport.new(function(s)
---   table.insert(lines, s)
--- end)
--- ui.mount(MyComponent, viewport)
--- ```
---
--- **Color support**
--- Segments with a `.color` field (`{ fg = "#rrggbb", bg = "#rrggbb" }`) are wrapped
--- in ANSI SGR truecolor sequences (`ESC[38;2;r;g;bm` for foreground,
--- `ESC[48;2;r;g;bm` for background) followed by a reset (`ESC[0m`).
--- Segments without color are emitted as plain text.
---
--- **Limitations**
--- - `is_focused()` always returns `false`; keyboard-driven interactions are not
---   supported in a stdout context.
--- - `get_id()`, `get_bufnr()`, and `get_ns_id()` return `-1` (not applicable).
--- - `open()`, `close()`, `enable_edits()`, and `disable_edits()` are no-ops.
---@class ascii-ui.StdoutViewport : ascii-ui.Viewport
---@field private write ascii-ui.StdoutViewport.Writer
local StdoutViewport = {}
StdoutViewport.__index = StdoutViewport

local ESC = "\027"
local RESET = ESC .. "[0m"
local CLEAR_SCREEN = ESC .. "[H" .. ESC .. "[2J"
local ANSI_SGR_FMT = ESC .. "[%d;2;%d;%d;%dm"
local SGR_FG = 38 -- ANSI SGR code: set foreground color (truecolor)
local SGR_BG = 48 -- ANSI SGR code: set background color (truecolor)
local HEX_R = { 2, 3 } -- byte positions of red channel in "#rrggbb"
local HEX_G = { 4, 5 } -- byte positions of green channel
local HEX_B = { 6, 7 } -- byte positions of blue channel

--- Convert a hex color string like "#rrggbb" to an ANSI truecolor escape.
---@param hex string
---@param is_bg boolean
---@return string
local function hex_to_ansi(hex, is_bg)
	local r = tonumber(hex:sub(HEX_R[1], HEX_R[2]), 16)
	local g = tonumber(hex:sub(HEX_G[1], HEX_G[2]), 16)
	local b = tonumber(hex:sub(HEX_B[1], HEX_B[2]), 16)
	return ANSI_SGR_FMT:format(is_bg and SGR_BG or SGR_FG, r, g, b)
end

--- Build the ANSI escape prefix for a colored segment.
--- Pure: depends only on its argument, no side effects.
---@param seg ascii-ui.Segment
---@return string  ANSI escape sequence (empty string if segment has no color)
local function seg_to_ansi(seg)
	if not seg.color then
		return ""
	end
	local fg = seg.color.fg and hex_to_ansi(seg.color.fg, false) or ""
	local bg = seg.color.bg and hex_to_ansi(seg.color.bg, true) or ""
	return fg .. bg
end

--- Build a map of `{ [line_index] = { {col, len, ansi}, ... } }` from the
--- buffer's colored segments. Pure: reads from buffer, returns a new table.
---@param buffer ascii-ui.Buffer
---@return table<integer, {col:integer, len:integer, ansi:string}[]>
local function build_color_map(buffer)
	return vim.iter(buffer:iter_colored_segments()):fold({}, function(acc, result)
		local pos = result.position
		local seg = result.segment
		if not acc[pos.line] then
			acc[pos.line] = {}
		end
		table.insert(acc[pos.line], { col = pos.col, len = seg:raw_len(), ansi = seg_to_ansi(seg) })
		return acc
	end)
end

--- Render a single plain-text line with ANSI color spans applied.
--- Pure: depends only on its arguments, no side effects.
---@param line string         Plain text for this line.
---@param spans {col:integer, len:integer, ansi:string}[]|nil  Color spans (unsorted).
---@return string
local function render_line(line, spans)
	if not spans or #spans == 0 then
		return line
	end
	table.sort(spans, function(a, b)
		return a.col < b.col
	end)
	local state = vim.iter(spans):fold({ result = "", cursor = 1 }, function(s, span)
		if span.col > s.cursor then
			s.result = s.result .. line:sub(s.cursor, span.col - 1)
		end
		s.result = s.result .. span.ansi .. line:sub(span.col, span.col + span.len - 1) .. RESET
		s.cursor = span.col + span.len
		return s
	end)
	if state.cursor <= #line then
		state.result = state.result .. line:sub(state.cursor)
	end
	return state.result
end

--- Creates a new StdoutViewport.
---@param writer? ascii-ui.StdoutViewport.Writer  Output function. Defaults to `io.write`.
---@return ascii-ui.StdoutViewport
function StdoutViewport.new(writer)
	local state = { write = writer or function(s)
		io.write(s)
	end }
	setmetatable(state, StdoutViewport)
	return state
end

--- No-op. StdoutViewport requires no initialisation.
function StdoutViewport.open(_) end

--- No-op. StdoutViewport requires no teardown.
function StdoutViewport.close(_) end

--- Renders `buffer` to stdout.
---
--- Each call clears the terminal (`ESC[H ESC[2J`) and writes every line.
--- Colored segments are wrapped in ANSI truecolor sequences; the remainder
--- of each line is written as plain text.
---@param buffer ascii-ui.Buffer
function StdoutViewport:update(buffer)
	local color_map = build_color_map(buffer)
	local rendered = vim.iter(ipairs(buffer:to_lines()))
		:map(function(i, line)
			return render_line(line, color_map[i])
		end)
		:totable()
	self.write(CLEAR_SCREEN .. table.concat(rendered, "\n") .. "\n")
end

--- Always returns `false`. Stdout has no concept of focus.
---@return boolean
function StdoutViewport.is_focused(_)
	return false
end

--- No-op. Stdout is always writable.
function StdoutViewport.enable_edits(_) end

--- No-op. Stdout is always writable.
function StdoutViewport.disable_edits(_) end

--- Returns `-1`. Window ids are not applicable to stdout.
---@return integer
function StdoutViewport.get_id(_)
	return -1
end

--- Returns `-1`. Buffer numbers are not applicable to stdout.
---@return integer
function StdoutViewport.get_bufnr(_)
	return -1
end

--- Returns `-1`. Namespace ids are not applicable to stdout.
---@return integer
function StdoutViewport.get_ns_id(_)
	return -1
end

return StdoutViewport
