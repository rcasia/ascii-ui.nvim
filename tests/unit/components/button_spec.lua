pcall(require, "luacov")
---@module "luassert"
local eq = assert.are.same

local Buffer = require("ascii-ui.buffer")
local Button = require("ascii-ui.components.button")

describe("Paragraph", function()
	it("should create", function()
		Button:new({ label = "hello world!" })
	end)

	it("should render", function()
		local content = "Send"
		local button = Button:new({ label = content })

		---@return string
		local lines = function()
			return Buffer:new(unpack(button:render())):to_string()
		end
		eq([[Send]], lines())
	end)
end)
