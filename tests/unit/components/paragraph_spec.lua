pcall(require, "luacov")
---@module "luassert"
local eq = assert.are.same

local Buffer = require("ascii-ui.buffer")
local Paragraph = require("ascii-ui.components.paragraph")

describe("Paragraph", function()
	it("should create", function()
		local content = "hello world!"
		local txt_input = Paragraph:new({ content = content })
		eq(content, txt_input.content)
	end)

	it("should render", function()
		local content = "hello world!"
		local txt_input = Paragraph:new({ content = content })

		---@return string
		local lines = function()
			return Buffer:new(unpack(txt_input:render())):to_string()
		end
		eq([[hello world!]], lines())
	end)
end)
