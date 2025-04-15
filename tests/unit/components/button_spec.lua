pcall(require, "luacov")
---@module "luassert"
local eq = assert.are.same

local highlights = require("ascii-ui.highlights")
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

	it("has background color", function()
		local content = "Send"
		local button = Button:new({ label = content })

		local line = button:render()[1]
		local fragment = line.elements[1]

		eq(highlights.BUTTON, fragment.highlight)
	end)
end)
