require("luassert")
local eq = assert.are.same

local Box = require("one-ui.components.box")

describe("box", function()
	it("admits plain text", function()
		local box = Box:new()
		box:add_child("Hello world")
		eq(#box:children(), 1)
	end)
end)
