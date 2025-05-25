print("gendocs.lua running...")

-- clone the mini.doc repository if it doesn't exist
vim.system({ "git", "clone", "git@github.com:echasnovski/mini.doc.git", "./deps/mini.doc" })

-- Añade el path correcto al package.path
local doc_path = "./deps/mini.doc/lua/?.lua;./deps/mini.doc/lua/?/init.lua"
package.path = doc_path .. ";" .. package.path

local mini = require("mini.doc")
mini.setup()
mini.generate({
	"lua/ascii-ui/init.lua",
})
