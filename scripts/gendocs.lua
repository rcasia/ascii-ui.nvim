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
vim.system({ "git", "clone", "https://github.com/echasnovski/mini.doc.git", mini_doc_path }):wait()

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

table.sort(project_files)

local mini = require("mini.doc")
mini.setup()

-- Derive the dotted module prefix from a file's directory portion.
-- "/abs/path/to/lua/ascii-ui/hooks/use_state.lua" -> "ascii-ui.hooks"
local function path_to_module_prefix(filepath)
	local rel = filepath:match("[/\\]lua[/\\](.+)[/\\][^/\\]+%.lua$")
	if not rel then
		return nil
	end
	return (rel:gsub("[/\\]", "."))
end

-- Rewrite a single @tag or @signature line so the module prefix comes from
-- the file path rather than the Lua identifier used in the source.
--
-- The function name portion extracted from the inferred line depends on
-- the style of the identifier:
--
--   lowercase-starting (bare function or module path):
--     "useTimeout()"               -> prefix + ".useTimeout()"
--     "ascii_ui.hooks.useState()"  -> prefix + ".useState()"   (last segment)
--
--   uppercase-starting (class static/instance method):
--     "Buffer.new()"               -> prefix + ".Buffer.new()"  (keep class)
--     "Buffer:width()"             -> prefix + ".Buffer:width()" (keep class)
--
-- This preserves uniqueness: Buffer.new and BufferLine.new in the same
-- directory both become distinct tags (ascii-ui.buffer.Buffer.new vs
-- ascii-ui.buffer.BufferLine.new) instead of colliding on "new".
local function rewrite_line(line, prefix, section_id)
	if section_id == "@tag" then
		local is_callable = line:match("%(%)$") ~= nil
		local bare = line:gsub("%(%)$", "")
		local first_char = bare:sub(1, 1)
		local func_part
		if first_char == first_char:lower() and first_char ~= first_char:upper() then
			-- lowercase: strip any leading module path, keep just the last segment
			func_part = bare:match("%.([^%.]+)$") or bare
		else
			-- uppercase: class method — preserve "ClassName.method" or "ClassName:method"
			func_part = bare
		end
		return prefix .. "." .. func_part .. (is_callable and "()" or "")
	elseif section_id == "@signature" then
		local before_args, args = line:match("^(.-)(%b())$")
		local identifier = before_args or line
		args = args or ""
		local first_char = identifier:sub(1, 1)
		local func_part
		if first_char == first_char:lower() and first_char ~= first_char:upper() then
			func_part = identifier:match("%.([^%.]+)$") or identifier
		else
			func_part = identifier
		end
		return prefix .. "." .. func_part .. args
	end
	return line
end

local hooks = vim.deepcopy(mini.default_hooks)
local default_block_pre = hooks.block_pre

hooks.block_pre = function(b)
	-- Let mini.doc infer @tag and @signature from the afterlines first.
	default_block_pre(b)

	local file = b.parent
	if not file or not file.info or not file.info.path then
		return
	end

	local prefix = path_to_module_prefix(file.info.path)
	if not prefix then
		return
	end

	for _, section in ipairs(b) do
		if section.type == "section" and (section.info.id == "@tag" or section.info.id == "@signature") then
			for i, line in ipairs(section) do
				section[i] = rewrite_line(line, prefix, section.info.id)
			end
		end
	end
end

-- Allow overriding output via environment variable
local output = os.getenv("DOC_OUTPUT_FILE")
if output == nil or output == "" then
	mini.generate(project_files, nil, { hooks = hooks })
else
	mini.generate(project_files, output, { hooks = hooks })
end
