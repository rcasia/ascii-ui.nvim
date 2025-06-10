local LUX_DIR = ".lux"
local LUA_VERSION = "5.1"

local lux_dependencies = vim.fn.glob(LUX_DIR .. "/" .. LUA_VERSION .. "/**/src", true, true)

for _, dir in ipairs(lux_dependencies) do
	package.path = table.concat({
		dir .. "/?.lua",
		dir .. "/?/init.lua",
		package.path,
	}, ";")
end
