pcall(require, "luacov")
---@module "luassert"

local _ = require("ascii-ui")
local config = require("ascii-ui.config")
local renderer = require("ascii-ui.renderer"):new(config)

local eq = assert.are.same

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

	it("translates from composed dsl to buffer", function()
		local actual = renderer:render([[
		<Layout>
			<Paragraph content="Hello World!" />
		</Layout>
    ]])

		eq([[Hello World!]], actual:to_string())

		local actual_2 = renderer:render([[
		<Layout>
			<Paragraph content="Hello from level 1!" />
			<Layout>
				<Paragraph content="Hello from level 2!" />
				<Layout>
					<Paragraph content="Hello from level 3!" />
				</Layout>
			</Layout>
		</Layout>
    ]])

		eq(
			[[Hello from level 1!

Hello from level 2!

Hello from level 3!]],
			actual_2:to_string()
		)
	end)
end)
