pcall(require, "luacov")
---@module "luassert"
local eq = assert.are.same

local highlights = require("ascii-ui.highlights")
local Buffer = require("ascii-ui.buffer")
local Button = require("ascii-ui.components.button")

describe("Button", function()
	it("functional", function()
		local bufferlines = Button.fun({ label = "Send" })()
		---@return string
		local lines = function()
			return Buffer:new(unpack(bufferlines))
		end

		eq([[Send]], lines():to_string())
		eq(highlights.BUTTON, lines().lines[1].elements[1].highlight)
	end)
end)
