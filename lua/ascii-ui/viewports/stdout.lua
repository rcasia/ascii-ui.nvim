---@alias ascii-ui.StdoutViewport.Writer fun(s: string)

---@class ascii-ui.StdoutViewport : ascii-ui.Viewport
---@field private write ascii-ui.StdoutViewport.Writer
local StdoutViewport = {}
StdoutViewport.__index = StdoutViewport

local RESET = "\027[0m"

--- Convert a hex color string like "#rrggbb" to an ANSI truecolor escape.
--- @param hex string
--- @param is_bg boolean
--- @return string
local function hex_to_ansi(hex, is_bg)
	local r = tonumber(hex:sub(2, 3), 16)
	local g = tonumber(hex:sub(4, 5), 16)
	local b = tonumber(hex:sub(6, 7), 16)
	local code = is_bg and 48 or 38
	return ("\027[%d;2;%d;%d;%dm"):format(code, r, g, b)
end

---@param writer? ascii-ui.StdoutViewport.Writer defaults to io.write
---@return ascii-ui.StdoutViewport
function StdoutViewport.new(writer)
	local state = { write = writer or function(s)
		io.write(s)
	end }
	setmetatable(state, StdoutViewport)
	return state
end

function StdoutViewport.open(_) end

function StdoutViewport.close(_) end

---@param buffer ascii-ui.Buffer
function StdoutViewport:update(buffer)
	-- Build a map of { [line][col] = ansi_prefix } from colored segments
	local color_map = {}
	for result in buffer:iter_colored_segments() do
		local pos = result.position
		local seg = result.segment
		if not color_map[pos.line] then
			color_map[pos.line] = {}
		end
		local ansi = ""
		if seg.color then
			if seg.color.fg then
				ansi = ansi .. hex_to_ansi(seg.color.fg, false)
			end
			if seg.color.bg then
				ansi = ansi .. hex_to_ansi(seg.color.bg, true)
			end
		end
		-- store: start col, length, ansi prefix
		table.insert(color_map[pos.line], { col = pos.col, len = seg:raw_len(), ansi = ansi })
	end

	local plain_lines = buffer:to_lines()
	local out = { "\027[H\027[2J" }

	for line_idx, line in ipairs(plain_lines) do
		local spans = color_map[line_idx]
		if not spans or #spans == 0 then
			table.insert(out, line)
		else
			-- sort spans by col ascending
			table.sort(spans, function(a, b)
				return a.col < b.col
			end)
			local result = ""
			local cursor = 1 -- byte position in `line` (1-based)
			for _, span in ipairs(spans) do
				local start = span.col -- 1-based byte col
				if start > cursor then
					result = result .. line:sub(cursor, start - 1)
				end
				result = result .. span.ansi .. line:sub(start, start + span.len - 1) .. RESET
				cursor = start + span.len
			end
			if cursor <= #line then
				result = result .. line:sub(cursor)
			end
			table.insert(out, result)
		end
	end

	self.write(table.concat(out, "\n") .. "\n")
end

---@return boolean
function StdoutViewport.is_focused(_)
	return false
end

function StdoutViewport.enable_edits(_) end

function StdoutViewport.disable_edits(_) end

---@return integer
function StdoutViewport.get_id(_)
	return -1
end

---@return integer
function StdoutViewport.get_bufnr(_)
	return -1
end

---@return integer
function StdoutViewport.get_ns_id(_)
	return -1
end

return StdoutViewport
