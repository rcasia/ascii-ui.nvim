pcall(require, "luacov")
---@module "luassert"

local Buffer = require("ascii-ui.buffer.buffer")
local BufferLine = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
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

	it("has the longest buffer line length as width", function()
		local longest = BufferLine:new(Element:new("longest line"), Element:new("ever written"))

		local b = Buffer:new(BufferLine:new(Element:new("short")), BufferLine:new(Element:new("longer line")), longest)

		eq(longest:len(), b:width())
	end)

	it("has the number of lines as height", function()
		local b = Buffer:new(BufferLine:new(), BufferLine:new(), BufferLine:new())
		eq(3, b:height())
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
			local target_a = Element:new("this is focusable", true)
			local target_b = Element:new("another focusable", true)
			local target_c = Element:new("yet another focusable", true)
			local b = Buffer:new(
				BufferLine:new(Element:new("this is not focusable"), target_a),
				BufferLine:new(Element:new("not focusable either"), target_b),
				BufferLine:new(),
				BufferLine:new(),
				BufferLine:new(target_c)
			)
			local next = b:iter_focusables()
			local found_a = next()
			eq(target_a, found_a)

			local found_b = next()
			eq(target_b, found_b)

			local found_c = next()
			eq(target_c, found_c)

			assert.is_nil(next())
		end)

		it("finds the next colored element and its position", function()
			local highlight = "SomeHighlight"
			local target_a = Element:new("this is focusable", false, {}, highlight)
			local target_b = Element:new("another focusable", true, {}, highlight)
			local target_c = Element:new("yet another focusable", true, {}, highlight)
			local b = Buffer:new(
				BufferLine:new(Element:new("this is not focusable"), target_a),
				BufferLine:new(Element:new("not focusable either"), target_b),
				BufferLine:new(),
				BufferLine:new(),
				BufferLine:new(target_c)
			)
			local next = b:iter_colored_elements()
			local found_a = assert(next())
			eq(target_a, found_a.element)
			eq({ line = 1, col = 22 }, found_a.position)

			local found_b = assert(next())
			eq(target_b, found_b.element)
			eq({ line = 2, col = 21 }, found_b.position)

			local found_c = assert(next())
			eq(target_c, found_c.element)
			eq({ line = 5, col = 1 }, found_c.position)

			assert.is_nil(next())
		end)

		it("should find element by id", function()
			local target = Element:new("target element")
			local b = Buffer:new(
				BufferLine:new(Element:new("some element A")),
				BufferLine:new(Element:new("some element B"), target),
				BufferLine:new(Element:new("some elmenent C", true))
			)

			local found = b:find_element_by_id(target.id)
			eq(target, found)
		end)

		it("should find element by position", function()
			local target_a = Element:new("target element")
			local element_before_target = Element:new("some element B")
			local b = Buffer:new(
				BufferLine:new(Element:new("some element A")),
				BufferLine:new(element_before_target, target_a),
				BufferLine:new(Element:new("some element C"))
			)

			eq(target_a, b:find_element_by_position({ line = 2, col = element_before_target:len() + 1 }))
		end)

		it("returns nil when not found", function()
			local b = Buffer:new(
				BufferLine:new(Element:new("some element A")),
				BufferLine:new(element_before_target, target_a),
				BufferLine:new(Element:new("some element C"))
			)

			assert.is_nil(b:find_element_by_position({ line = math.huge, col = 1 }))
			assert.is_nil(b:find_element_by_position({ line = 1, col = math.huge }))
		end)
	end)
end)
