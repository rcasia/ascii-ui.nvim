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
	local testing_framework_path = vim.fn.expand("$GITHUB_WORKSPACE/../mini.test")
	if vim.fn.isdirectory(testing_framework_path) == 0 then
		vim.fn.system({
			"git",
			"clone",
			"git@github.com:nvim-mini/mini.test.git",
			testing_framework_path,
		})
	end

	package.path = table.concat({
		testing_framework_path .. "/lua/?.lua",
		testing_framework_path .. "/lua/?/init.lua",
		package.path,
	}, ";")
end

-- Add current directory to 'runtimepath' to be able to use 'lua' files
vim.cmd([[let &rtp.=','.getcwd()]])
