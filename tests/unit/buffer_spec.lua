pcall(require, "luacov")
---@module "luassert"

local Buffer = require("ascii-ui.buffer")
local BufferLine = require("ascii-ui.buffer.bufferline")
local Segment = require("ascii-ui.buffer.element")
local eq = assert.are.same

describe("buffer", function()
	describe("Segment", function()
		it("should count ascii characters", function()
			local s = "ascii"
			local segment = Segment:new({ content = s })
			eq(5, segment:len())
		end)
		it("should count unicode characters", function()
			local s = "a😊日€𐍈"
			local segment = Segment:new({ content = s })
			eq(5, segment:len())
		end)
	end)

	it("should be able to create a buffer", function()
		local b = Buffer.new()
		eq("table", type(b))
	end)

	it("creates buffer from array of strings", function()
		local b = Buffer.from_lines({ "1test", "2test" })
		eq({ "1test", "2test" }, b:to_lines())
	end)

	it("has the longest buffer line length as width", function()
		local longest = BufferLine.new(Segment:new("longest line"), Segment:new("ever written"))

		local b = Buffer.new(BufferLine.new(Segment:new("short")), BufferLine.new(Segment:new("longer line")), longest)

		eq(longest:len(), b:width())
	end)

	it("has the number of lines as height", function()
		local b = Buffer.new(BufferLine.new(), BufferLine.new(), BufferLine.new())
		eq(3, b:height())
	end)

	describe("find_focusable", function()
		it("should find the next focusable element", function()
			local target_a = Segment:new("this is focusable", true)
			local target_b = Segment:new("another focusable", true)
			local target_c = Segment:new("yet another focusable", true)
			local b = Buffer.new(
				BufferLine.new(Segment:new("this is not focusable"), target_a),
				BufferLine.new(Segment:new("not focusable either"), target_b),
				BufferLine.new(),
				BufferLine.new(),
				BufferLine.new(target_c)
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

		it("finds next focusable element from position", function()
			local target_a = Segment:new({ content = "this is focusable", is_focusable = true })
			local target_b = Segment:new("another focusable", true)
			local target_c = Segment:new("yet another focusable", true)
			local b = Buffer.new(
				Segment:new("this is not focusable"):wrap():append(target_a:wrap()),
				Segment:new("not focusable either"):wrap():append(target_b:wrap()),
				BufferLine.new(),
				Segment:new("not focusable either"):wrap():append(target_c:wrap())
			)

			eq({ found = true, pos = { line = 1, col = 21 } }, b:find_next_focusable({ line = 1, col = 1 }))
			eq({ found = true, pos = { line = 2, col = 20 } }, b:find_next_focusable({ line = 1, col = 22 }))
			eq({ found = true, pos = { line = 2, col = 20 } }, b:find_next_focusable({ line = 2, col = 1 }))
			eq({ found = true, pos = { line = 4, col = 20 } }, b:find_next_focusable({ line = 3, col = 1 }))
			eq(b:find_next_focusable(), b:find_next_focusable({ line = 1, col = 1 }))
		end)

		it("returns same input position when not found", function()
			local b = Buffer.new(
				BufferLine.new(Segment:new("this is not focusable")),
				BufferLine.new(Segment:new("not focusable either"))
			)

			eq({ found = false, pos = { line = 1, col = 10 } }, b:find_next_focusable({ line = 1, col = 10 }))
			eq({ found = false, pos = { line = 2, col = 10 } }, b:find_next_focusable({ line = 2, col = 10 }))
		end)

		describe("finds last focusable from position", function()
			local target_a = Segment:new("this is focusable", true)
			local target_b = Segment:new("another focusable", true)
			local target_c = Segment:new("yet another focusable", true)
			local other_line = Segment:new("focusable", true)
			local b = Buffer.new(
				BufferLine.new(Segment:new("this is not focusable"), target_a),
				BufferLine.new(Segment:new("not focusable either"), target_b),
				BufferLine.new(),
				BufferLine.new(),
				BufferLine.new(other_line, target_c, other_line)
			)

			it("1", function()
				eq({ found = true, pos = { line = 2, col = 20 } }, b:find_last_focusable({ line = 3, col = 1 }))
			end)

			it("2", function()
				eq({ found = true, pos = { line = 1, col = 21 } }, b:find_last_focusable({ line = 2, col = 1 }))
			end)

			it("3", function()
				eq({ found = false, pos = { line = 1, col = 0 } }, b:find_last_focusable({ line = 1, col = 0 }))
			end)

			it("4", function()
				eq({ found = true, pos = { line = 5, col = 9 } }, b:find_last_focusable({ line = 5, col = 30 }))
			end)

			local unfocusable = Segment:new({ content = "o" })
			local focusable = Segment:new({ content = "x", is_focusable = true })
			local buf = Buffer.new(BufferLine.new(focusable, unfocusable, focusable, unfocusable, focusable))

			it("5", function()
				eq({ found = true, pos = { line = 1, col = 2 } }, buf:find_last_focusable({ line = 1, col = 4 }))
			end)
		end)

		it("returns not found when there is not last focusable", function()
			local b = Buffer.new(
				BufferLine.new(Segment:new("this is not focusable")),
				BufferLine.new(Segment:new("not focusable either"))
			)

			eq({ found = false, pos = { line = 1, col = 10 } }, b:find_last_focusable({ line = 1, col = 10 }))
			eq({ found = false, pos = { line = 2, col = 10 } }, b:find_last_focusable({ line = 2, col = 10 }))
		end)

		it("finds the next colored element and its position", function()
			local highlight = "SomeHighlight"
			local target_a = Segment:new("this is focusable", false, {}, highlight)
			local target_b = Segment:new("another focusable", true, {}, highlight)
			local target_c = Segment:new("yet another focusable", true, {}, highlight)
			local b = Buffer.new(
				BufferLine.new(Segment:new("this is not focusable"), target_a),
				BufferLine.new(Segment:new("not focusable either"), target_b),
				BufferLine.new(),
				BufferLine.new(),
				BufferLine.new(target_c)
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
			local target = Segment:new("target element")
			local b = Buffer.new(
				BufferLine.new(Segment:new("some element A")),
				BufferLine.new(Segment:new("some element B"), target),
				BufferLine.new(Segment:new("some elmenent C", true))
			)

			local found = b:find_element_by_id(target.id)
			eq(target, found)
		end)

		it("should find element by position", function()
			local target_a = Segment:new("target element")
			local element_before_target = Segment:new("some element B")
			local b = Buffer.new(
				BufferLine.new(Segment:new("some element A")),
				BufferLine.new(element_before_target, target_a),
				BufferLine.new(Segment:new("some element C"))
			)

			eq(target_a, b:find_element_by_position({ line = 2, col = element_before_target:len() + 1 }))
			eq(target_a, b:find_element_by_position({ line = 2, col = element_before_target:len() }))
		end)

		it("returns nil when not found", function()
			local b = Buffer.new(
				--
				BufferLine.new(Segment:new("some element A")),
				BufferLine.new(Segment:new("some element C"))
			)

			assert.is_nil(b:find_element_by_position({ line = math.huge, col = 1 }))
			assert.is_nil(b:find_element_by_position({ line = 1, col = math.huge }))
		end)
	end)
end)
