require("luassert")

local Buffer = require("one-ui.buffer")
local BufferLine = require("one-ui.buffer.bufferline")
local Element = require("one-ui.buffer.element")
local eq = assert.are.same

describe("buffer", function()
	it("should be able to create a buffer", function()
		local b = Buffer:new()
		eq("table", type(b))
	end)

	it("creates buffer from array of strings", function()
		local b = Buffer.from_lines({ "1test", "2test" })
		eq({ "1test", "2test" }, b:to_lines())
	end)

	describe("find_focusable", function()
		it("should find the first focusable element", function()
			local e = Element:new("test")
			local l = BufferLine:new(e)
			local b = Buffer:new({ l })
			local found, position = b:find_focusable()
			eq(e, found)
			eq({ line = 1, col = 1 }, position)
		end)
	end)
end)
