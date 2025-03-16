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
			local e = Element:new("this is focusable", true)
			local b = Buffer:new(
				BufferLine:new(Element:new("this is not focusable")),
				BufferLine:new(Element:new("not focusable either"), e)
			)
			local found, position = b:find_focusable()
			eq(e, found)
			eq({ line = 2, col = 1 }, position)
		end)

		it("should find the next focusable element", function()
			local target1 = Element:new("this is focusable", true)
			local target2 = Element:new("another focusable", true)
			local b = Buffer:new(
				BufferLine:new(Element:new("this is not focusable"), target1),
				BufferLine:new(Element:new("not focusable either"), target2)
			)
			local next = b:iter_focusables()
			local found = next()
			eq(target1, found)

			local found2 = next()
			eq(target2, found2)

			assert.is_nil(next())
		end)
	end)
end)
