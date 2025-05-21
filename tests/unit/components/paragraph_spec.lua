pcall(require, "luacov")
---@module "luassert"
local eq = assert.are.same

local Buffer = require("ascii-ui.buffer")
local Paragraph = require("ascii-ui.components.paragraph")

describe("Paragraph", function()
	it("should render", function()
		local content = "hello world!"
		local paragraph = Paragraph({ content = content })()

		---@return string
		local lines = function()
			return Buffer.new(unpack(paragraph)):to_string()
		end
		eq([[hello world!]], lines())
	end)
end)
