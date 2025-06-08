pcall(require, "luacov")
---@module "luassert"
local eq = assert.are.same

local Paragraph = require("ascii-ui.components.paragraph")
local renderer = require("ascii-ui.renderer"):new()
local ui = require("ascii-ui")

describe("Paragraph", function()
	it("should render", function()
		local App = ui.createComponent("App", function()
			return Paragraph({ content = "hello world!" })
		end)

		eq([[hello world!]], renderer:render(App):to_string())
	end)
end)
