print("gendocs.lua running...")

local mini_doc_path = "./.deps/mini.doc"

-- clone the mini.doc repository if it doesn't exist
vim.system({ "git", "clone", "git@github.com:echasnovski/mini.doc.git", mini_doc_path })

-- Añade el path correcto al package.path
local doc_path = ("%s/lua/?.lua;%s/lua/?/init.lua"):format(mini_doc_path, mini_doc_path)
package.path = doc_path .. ";" .. package.path

-- take all the lua files in project
local project_files = {}
local handle = assert(io.popen("find ./lua -type f -name '*.lua'"))

print("Collecting Lua files from the project...")
for file in handle:lines() do
	project_files[#project_files + 1] = file
	print("Found file: " .. file)
end
handle:close()

local mini = require("mini.doc")
mini.setup()
mini.generate(project_files)
