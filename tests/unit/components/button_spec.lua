pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Button = require("ascii-ui.components.button")
local Renderer = require("ascii-ui.renderer")
local highlights = require("ascii-ui.highlights")
local ui = require("ascii-ui")

describe("Button", function()
	it("functional", function()
		local App = ui.createComponent("App", function()
			return Button({ label = "Send" })
		end)

		local buffer = Renderer:new():render(App)

		eq([[Send]], buffer:to_string())
		eq(highlights.BUTTON, buffer.lines[1].elements[1].highlight)
	end)
end)
