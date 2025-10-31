pcall(require, "luacov")
---@module "luassert"

local _ = require("ascii-ui")
local renderer = require("ascii-ui.renderer"):new()

local eq = require("tests.util.eq")
local pending = function(desc, fn)
	print("PENDING: " .. desc)
end

---@alias XmlNode { _type: "ROOT" | "ELEMENT", _name: string, _children: string, _attr: table<string, string> }

describe("DSL", function()
	it("translates from simple dsl to buffer", function()
		local actual = renderer:render([[
    <Slider />
    ]])

		eq([[●────────── 0%]], actual:to_string())

		local actual_render = renderer:render([[
    <Paragraph content="Hello World!" />
    ]])

		eq([[Hello World!]], actual_render:to_string())
	end)

	pending("translates from composed dsl to buffer", function()
		local actual = renderer:render([[
		<Column>
			<Paragraph content="Hello World!" />
		</Column>
    ]])

		eq([[Hello World!]], actual:to_string())

		local actual_2 = renderer:render([[
		<Column>
			<Paragraph content="Hello from level 1!" />
			<Column>
				<Paragraph content="Hello from level 2!" />
				<Column>
					<Paragraph content="Hello from level 3!" />
				</Column>
			</Column>
		</Column>
    ]])

		eq(
			[[Hello from level 1!

Hello from level 2!

Hello from level 3!]],
			actual_2:to_string()
		)
	end)
end)
