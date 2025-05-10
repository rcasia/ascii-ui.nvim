pcall(require, "luacov")
---@module "luassert"

local Cursor = require("ascii-ui.cursor")
local eq = assert.are.same

local mocked_cursor_position = { line = 1, col = 1 }
describe("Cursor", function()
	before_each(function()
		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.current_position = function()
			print("Mocked Cursor.current_position")
			return mocked_cursor_position
		end
	end)

	after_each(function()
		-- Cleanup code after each test
		Cursor._current_position = require("ascii-ui.cursor")._current_position
	end)

	it("triggers movement events", function()
		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.trigger_move_event()

		mocked_cursor_position = { line = 2, col = 1 }
		Cursor.trigger_move_event()

		eq(Cursor.DIRECTION.SOUTH, Cursor.last_movement_direction())
	end)

	it("triggers movement events in the opposite direction", function()
		mocked_cursor_position = { line = 2, col = 1 }
		Cursor.trigger_move_event()

		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.trigger_move_event()

		eq(Cursor.DIRECTION.NORTH, Cursor.last_movement_direction())
	end)
end)
