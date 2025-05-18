pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Buffer = require("ascii-ui.buffer")
local Button = require("ascii-ui.components.button")
local highlights = require("ascii-ui.highlights")

describe("Button", function()
	it("functional", function()
		local bufferlines = Button({ label = "Send" })()
		local lines = function()
			return Buffer:new(unpack(bufferlines))
		end

		eq([[Send]], lines():to_string())
		eq(highlights.BUTTON, lines().lines[1].elements[1].highlight)
	end)
end)
