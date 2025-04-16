pcall(require, "luacov")
---@module "luassert"
local renderer = require("ascii-ui.renderer")
local paragraph = require("ascii-ui.components.paragraph")
local logger = require("ascii-ui.logger")
local xml = require("tests.util.xml2lua")
local dom = require("tests.util.dom-handler")

local eq = assert.are.same

---@alias XmlNode { _type: "ROOT" | "ELEMENT", _name: string, _children: string, _attr: table<string, string> }

--- @return XmlNode
local function xml_parse(dsl)
	local parser = xml.parser(dom)
	parser:parse(dsl)
	return vim.deepcopy(dom.root._children[3])
end

local function undertest(dsl)
	local result = xml_parse(dsl)
	logger.info(vim.inspect(result))

	local tag_name = result._name
	if tag_name ~= "Paragrapgh" then
		error("tag_name not recognized: " .. vim.inspect(tag_name))
	end

	local props = result._attr

	return renderer:render(paragraph:new(props)):to_lines()
end

describe("DSL", function()
	it("translates from simple dsl to buffer", function()
		local expected = renderer:render(paragraph:new({ content = "Hello World!" })):to_lines()

		local actual = undertest([[
    <Paragrapgh content="Hello World!" />
    ]])

		eq(expected, actual)
	end)
end)
