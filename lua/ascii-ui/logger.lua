--- @class ascii-ui.Logger
local M = {}

-- Define log levels
--- @enum ascii-ui.Logger.LogLevel
local levels = {
	DEBUG = "DEBUG",
	INFO = "INFO",
	WARN = "WARN",
	ERROR = "ERROR",
}

-- Set default log level
M.level = levels.INFO

-- Get log file path
local log_dir = vim.fn.stdpath("data") .. "/ascii-ui"
local log_path = log_dir .. "/ascii-ui.log"

local function ensure_log_dir()
	if vim.fn.isdirectory(log_dir) == 0 then
		vim.fn.mkdir(log_dir, "p")
	end
end

-- Internal function to write a message to file
local function write_log(level, msg)
	if not level or not msg then
		return
	end
	ensure_log_dir()

	local file = io.open(log_path, "a")
	if file then
		local time = os.date("%Y-%m-%d %H:%M:%S")
		file:write(string.format("[%s] [%s] %s\n", time, level, msg))
		file:close()
	end
end

-- Public log functions
function M.debug(msg)
	if M.level == levels.DEBUG then
		write_log(levels.DEBUG, msg)
	end
end

function M.info(msg)
	if M.level == levels.DEBUG or M.level == levels.INFO then
		write_log(levels.INFO, msg)
	end
end

function M.warn(msg)
	if M.level ~= levels.ERROR then
		write_log(levels.WARN, msg)
	end
end

function M.error(msg)
	write_log(levels.ERROR, msg)
end

-- Optional: set log level
--- @param new_level ascii-ui.Logger.LogLevel
function M.set_level(new_level)
	if levels[new_level] then
		M.level = levels[new_level]
	end
end

return M
