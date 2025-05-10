pcall(require, "luacov")
---@module "luassert"

local Cursor = require("ascii-ui.cursor")
local EventListener = require("ascii-ui.events")

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
		EventListener:clear()
	end)

	it("detects south movement", function()
		local event_recieved = false
		EventListener:listen("CursorMovedSouth", function()
			event_recieved = true
		end)
		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.trigger_move_event()

		mocked_cursor_position = { line = 2, col = 1 }
		Cursor.trigger_move_event()

		eq(true, event_recieved)
	end)

	it("detects north movement", function()
		local event_recieved = false
		EventListener:listen("CursorMovedNorth", function()
			event_recieved = true
		end)
		mocked_cursor_position = { line = 2, col = 1 }
		Cursor.trigger_move_event()

		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.trigger_move_event()

		eq(true, event_recieved)
	end)

	it("detects EAST movement", function()
		local event_recieved = false
		EventListener:listen("CursorMovedEast", function()
			event_recieved = true
		end)
		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.trigger_move_event()

		mocked_cursor_position = { line = 1, col = 2 }
		Cursor.trigger_move_event()

		eq(true, event_recieved)
	end)

	it("detects WEST movement", function()
		local event_recieved = false
		EventListener:listen("CursorMovedWest", function()
			event_recieved = true
		end)
		mocked_cursor_position = { line = 1, col = 2 }
		Cursor.trigger_move_event()

		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.trigger_move_event()

		eq(true, event_recieved)
	end)

	it("does not trigger the move event when moved by Cursor", function()
		local event_recieved = false
		--- @type ascii-ui.EventType[]
		local events = { "CursorMovedSouth", "CursorMovedNorth", "CursorMovedEast", "CursorMovedWest" }
		for _, event in ipairs(events) do
			EventListener:listen(event, function()
				event_recieved = true
			end)
		end

		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.trigger_move_event()

		mocked_cursor_position = { line = 1, col = 1 }
		Cursor.trigger_move_event()

		eq(false, event_recieved)
	end)
end)
