pcall(require, "luacov")
---@module "luassert"
local ui = require("ascii-ui")
local config = require("ascii-ui.config")
local renderer = require("ascii-ui.renderer"):new(config)
local logger = require("ascii-ui.logger")

local eq = assert.are.same

---@alias XmlNode { _type: "ROOT" | "ELEMENT", _name: string, _children: string, _attr: table<string, string> }

describe("DSL", function()
	it("translates from simple dsl to buffer", function()
		local actual = renderer:render_xml([[
    <Slider content="s" />
    ]])

		eq([[●────────── 0%]], actual:to_string())
	end)

	it("translates from simple dsl to buffer", function()
		local actual = renderer:render_xml([[
    <Paragraph content="Hello World!" />
    ]])

		eq([[Hello World!]], actual:to_string())
	end)
end)
