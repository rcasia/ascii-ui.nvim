pcall(require, "luacov")
---@module "luassert"

local Cursor = require("ascii-ui.cursor")
local eq = assert.are.same

local mocked_cursor_position = { line = 1, col = 1 }
describe("Cursor", function()
	before_each(function()
		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.current_position = function()
			return mocked_cursor_position
		end
	end)

	after_each(function()
		-- Cleanup code after each test
		Cursor._current_position = require("ascii-ui.cursor")._current_position
	end)

	it("detects south movement", function()
		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.trigger_move_event()

		mocked_cursor_position = { line = 2, col = 1 }
		Cursor.trigger_move_event()

		eq(Cursor.DIRECTION.SOUTH, Cursor.last_movement_direction())
	end)

	it("detects north movement", function()
		mocked_cursor_position = { line = 2, col = 1 }
		Cursor.trigger_move_event()

		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.trigger_move_event()

		eq(Cursor.DIRECTION.NORTH, Cursor.last_movement_direction())
	end)

	it("detects EAST movement", function()
		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.trigger_move_event()

		mocked_cursor_position = { line = 1, col = 2 }
		Cursor.trigger_move_event()

		eq(Cursor.DIRECTION.EAST, Cursor.last_movement_direction())
	end)

	it("detects WEST movement", function()
		mocked_cursor_position = { line = 1, col = 2 }
		Cursor.trigger_move_event()

		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.trigger_move_event()

		eq(Cursor.DIRECTION.WEST, Cursor.last_movement_direction())
	end)
end)
