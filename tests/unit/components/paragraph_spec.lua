pcall(require, "luacov")
local assert = require("luassert")
local eq = assert.are.same

local Paragraph = require("ascii-ui.components.paragraph")
local renderer = require("ascii-ui.renderer"):new()
local ui = require("ascii-ui")

describe("Paragraph", function()
	it("renders simple text", function()
		local App = ui.createComponent("App", function()
			return Paragraph({ content = "hello world!" })
		end)

		eq([[hello world!]], renderer:render(App):to_string())
	end)

	it("renders text with new lines", function()
		local App = ui.createComponent("App", function()
			return Paragraph({ content = "hello\nworld!" })
		end)

		eq({ "hello", "world!" }, renderer:render(App):to_lines())
	end)
end)
