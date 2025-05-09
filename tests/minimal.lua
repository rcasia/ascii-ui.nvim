local M = {}

local function tempdir(plugin)
	if jit.os == "Windows" then
		return "D:\\tmp\\" .. plugin
	end
	return ".tests/site/pack/deps/start/" .. plugin
end

local plenary_dir = os.getenv("PLENARY_DIR") or tempdir("plenary.nvim")
print("Plenary dir: " .. plenary_dir)
if vim.fn.isdirectory(plenary_dir) == 0 then
	vim.fn.system({
		"git",
		"clone",
		"https://github.com/nvim-lua/plenary.nvim",
		plenary_dir,
	})
end
vim.opt.rtp:append(".")
vim.opt.rtp:append(plenary_dir)

local root_dir = vim.fn.fnamemodify(vim.trim(vim.fn.system("git rev-parse --show-toplevel")), ":p"):gsub("/$", "")

package.path = string.format("%s;%s/?.lua;%s/?/init.lua", package.path, root_dir, root_dir)

vim.opt.packpath:prepend(root_dir .. "/.tests/site")

vim.cmd([[
  packadd plenary.nvim
]])

require("plenary.busted")

vim.cmd("runtime plugin/plenary.vim")

local logger = require("ascii-ui.logger")
logger.set_level("DEBUG")

return M
