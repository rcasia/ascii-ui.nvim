local Checkbox = require("one-ui.components.checkbox")
local Renderer = require("one-ui.renderer")
local assert = require("luassert")
local eq = assert.are.same

describe("renderer", function()
	it("should render a checkbox", function()
		local checkbox = Checkbox:new()
		local renderer = Renderer:new()
		eq("[ ]", renderer:render(checkbox))

		checkbox:toggle()
		eq("[X]", renderer:render(checkbox))
	end)
end)
