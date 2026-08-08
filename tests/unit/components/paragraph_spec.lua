pcall(require, "luacov")
---@module "luassert"
local eq = assert.are.same

local Paragraph = require("ascii-ui.components.paragraph")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")

describe("Paragraph", function()
	it("renders simple text", function()
		local App = ui.createComponent("App", function()
			return Paragraph({ content = "hello world!" })
		end)

		eq([[hello world!]], fiber.render(App):get_buffer():to_string())
	end)

	it("renders text with new lines", function()
		local App = ui.createComponent("App", function()
			return Paragraph({ content = "hello\nworld!" })
		end)

		eq({ "hello", "world!" }, fiber.render(App):get_buffer():to_lines())
	end)
end)
