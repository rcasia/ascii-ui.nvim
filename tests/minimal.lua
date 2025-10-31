local LUX_DIR = ".lux"
local LUA_VERSION = "5.1"
local RUNNING_ON_ACTIONS = os.getenv("GITHUB_ACTIONS") == "true"

local lux_dependencies = vim.fn.glob(LUX_DIR .. "/" .. LUA_VERSION .. "/**/src", true, true)

local add_to_luapath = function(dir)
	package.path = table.concat({
		dir .. "/?.lua",
		dir .. "/?/init.lua",
		package.path,
	}, ";")
end

-- add project dir first
add_to_luapath(".")

-- add lux test dependencies
for _, dir in ipairs(lux_dependencies) do
	add_to_luapath(dir)
end

-- if in github actions, add a clone of plenary to the package path
if RUNNING_ON_ACTIONS then
	local plenary_path = vim.fn.expand("$GITHUB_WORKSPACE/../plenary.nvim")
	if vim.fn.isdirectory(plenary_path) == 0 then
		vim.fn.system({
			"git",
			"clone",
			"https://github.com/nvim-lua/plenary.nvim",
			plenary_path,
		})
	end

	package.path = table.concat({
		plenary_path .. "/lua/?.lua",
		plenary_path .. "/lua/?/init.lua",
		package.path,
	}, ";")
end

-- ─────────────────────────────────────────────────────────────
-- Enable mini.test
-- ─────────────────────────────────────────────────────────────
require("mini.test").setup({
	collect = {
		emulate_busted = true,
		find_files = function()
			return vim.fn.globpath("tests", "**/*_spec.lua", true, true)
		end,
	},
	execute = {
		reporter = require("mini.test").gen_reporter.stdout(),
		stop_on_error = false,
	},
})
