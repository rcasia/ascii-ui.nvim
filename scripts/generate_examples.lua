-- read readme.md file
-- and search for code snippets starting with ```lua generate-example

print("generation started")
local f = assert(io.open("readme.md", "r"))
local readme_content = f:read("*all")
f:close()

-- get code snippets
-- local snippet = readme_content:gmatch("%-%- generate:start\n(.-)\n%-%- generate:end")()
local snippet = [[
local Options = require("ascii-ui.components.options")
local layout = require("ascii-ui.layout")
local ui = require("ascii-ui")

local projects = Options:new({
 title = "Project",
 options = {
  "Gradle - Groovy",
  "Gradle - Kotlin",
  "Maven",
 },
})

local langs = Options:new({
 title = "Language",
 options = {
  "Java",
  "Kotlin",
  "Groovy",
 },
})

local spring = Options:new({

 title = "Spring Boot",
 options = {
  "3.5.0 (SNAPSHOT)",
  "3.4.3",
  "3.3.10",
 },
})

return layout:new(projects, langs, spring):render()
]]

local ok, result = pcall(load(snippet)) ---@cast result ascii-ui.Buffer
if not ok then
	print("error in code snippet")
	print(result)
	return
end

local new_content = vim.iter(result:to_lines()):join("\n")
print(new_content)
print("generation ended")
