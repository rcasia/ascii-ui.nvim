---
--- metrics.lua — minimal module for counting and displaying simple metrics
---
--- Basic usage:
---   local metrics = require('metrics')
---   metrics:inc('hits')     -- adds 1
---   metrics:inc('foo', 3)   -- adds 3
---   metrics:set('bar', 10)
---   metrics:show()          -- displays a popup with the metrics
---
--- (Optional) Create user commands from init.lua:
---   vim.api.nvim_create_user_command('MetricsShow', function() require('metrics').show() end, {})
---   vim.api.nvim_create_user_command('MetricInc', function(opts)
---     require('metrics').inc(opts.fargs[1], tonumber(opts.fargs[2]) or 1)
---   end, { nargs = '+', complete = 'file' })
---
--- All annotations use **LuaCATS** (type format for LuaLS / sumneko).
---

---@alias MetricsKey string
---@alias MetricsValue number
---@alias MetricsStore table<MetricsKey, MetricsValue>

--- Options for `show`.
---@class MetricsShowOpts
---@field max_height? integer # maximum height of the popup.
---@field border? string      # border style for `nvim_open_win` (e.g., "rounded", "single").

--- Public API of the metrics module.
---@class Metrics
---@field get fun(key: MetricsKey): MetricsValue              # Gets the current value (0 if it does not exist).
---@field set fun(key: MetricsKey, value: MetricsValue): MetricsValue  # Sets an exact value and returns it.
---@field inc fun(key: MetricsKey, amount?: integer): MetricsValue     # Increments the value and returns the new total.
---@field reset fun()                                           # Clears all metrics.
---@field all fun(): MetricsStore                                # Shallow copy of all metrics.
---@field show fun(opts?: MetricsShowOpts): integer            # Opens a popup and returns the winid.
local Metrics = {}

-- In-memory storage
---@type MetricsStore
local store = {}

--- Returns the current value (0 if it does not exist).
---@param key MetricsKey
---@return MetricsValue value
function Metrics.get(key)
	return store[key] or 0
end

--- Sets an exact value and returns it.
---@param key MetricsKey
---@param value MetricsValue
---@return MetricsValue new_value
function Metrics.set(key, value)
	store[key] = tonumber(value) or 0
	return store[key]
end

--- Increments (default +1) and returns the new total.
---@param key MetricsKey
---@param amount? integer
---@return MetricsValue new_total
function Metrics.inc(key, amount)
	amount = tonumber(amount) or 1
	store[key] = (store[key] or 0) + amount
	return store[key]
end

--- Resets all metric storage.
function Metrics.reset()
	store = {}
end

--- Returns a copy with all metrics.
---@return MetricsStore copy
function Metrics.all()
	local out = {}
	for k, v in pairs(store) do
		out[k] = v
	end
	return out
end

--- Converts to text lines for display.
---@return string[] lines
local function as_lines()
	local lines = { "# Metrics" }
	-- Alphabetical order for stability
	local keys = {}
	for k in pairs(store) do
		table.insert(keys, k)
	end
	table.sort(keys)
	for _, k in ipairs(keys) do
		table.insert(lines, string.format("%s: %s", k, tostring(store[k])))
	end
	if #lines == 1 then
		table.insert(lines, "(vacío)")
	end
	return lines
end

--- Shows a very simple popup with the metrics.
---@param opts? MetricsShowOpts
---@return integer winid
function Metrics.show(opts)
	opts = opts or {}
	local lines = as_lines()
	local width = 0
	for _, l in ipairs(lines) do
		width = math.max(width, #l)
	end
	width = math.max(width, 20)
	local height = math.min(#lines, opts.max_height or 20)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		style = "minimal",
		border = opts.border or "rounded",
	})

	-- Close with q or <Esc>
	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end
	vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, silent = true })
	vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true, silent = true })

	-- Highlights the title if 'Title' exists
	pcall(vim.api.nvim_buf_add_highlight, buf, -1, "Title", 0, 0, -1)

	return win
end

return Metrics
