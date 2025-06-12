print("gendocs.lua running...")

local mini_doc_path = "./.deps/mini.doc"
local EXCLUDED_FILES = {
	".-/lib/.-",
}

local function matches_any(path, patterns)
	for _, pattern in ipairs(patterns) do
		if path:match(pattern) then
			return true
		end
	end
	return false
end

-- clone the mini.doc repository if it doesn't exist
vim.system({ "git", "clone", "git@github.com:echasnovski/mini.doc.git", mini_doc_path }):wait()

-- add mini.doc to package.path
local doc_path = ("%s/lua/?.lua;%s/lua/?/init.lua"):format(mini_doc_path, mini_doc_path)
package.path = doc_path .. ";" .. package.path

-- take all the lua files in project
local handle = assert(io.popen("find ./lua -type f -name '*.lua'"))

print("Collecting Lua files from the project...")
local project_files = vim.iter(handle:lines())
	:filter(function(file)
		return not matches_any(file, EXCLUDED_FILES)
	end)
	:map(function(file)
		print("Found file: " .. file)
		return file
	end)
	:totable()

handle:close()

local mini = require("mini.doc")
mini.setup()

-- Allow overriding output via environment variable
local output = os.getenv("DOC_OUTPUT_FILE")
if output == nil or output == "" then
	mini.generate(project_files)
else
	mini.generate(project_files, output)
end
