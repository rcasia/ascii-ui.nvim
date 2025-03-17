require("luassert")
local eq = assert.are.same

local Box = require("ascii-ui.components.box")

describe("box", function()
	it("admits plain text", function()
		local box = Box:new()
		box:set_child("Hello world")
		eq(box:child(), "Hello world")
	end)

	it("should throw error when height less than 3", function()
		local status, err = pcall(function()
			Box:new({ height = 2 })
		end)
		assert(not status)
		assert.has_string("box component failed: height cannot be less than 3", err)
	end)
end)
