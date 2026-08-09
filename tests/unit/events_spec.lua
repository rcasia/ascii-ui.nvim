pcall(require, "luacov")

local Command = require("ascii-ui.commands")
local EventBus = require("ascii-ui.events")

describe("EventBus command system", function()
	describe("dispatch and on", function()
		it("dispatch calls registered handlers for command type", function()
			local bus = EventBus.new()
			local called = false
			local received_command = nil

			bus:on("CLOSE_WINDOW", function(cmd)
				called = true
				received_command = cmd
			end)

			local cmd = Command.CloseWindow({ window_id = 42 })
			bus:dispatch(cmd)

			assert.is_true(called)
			assert.are.equal(cmd, received_command)
			assert.are.equal(42, received_command.window_id)
		end)

		it("dispatch calls multiple handlers for same command type", function()
			local bus = EventBus.new()
			local call_count = 0

			bus:on("SELECT", function()
				call_count = call_count + 1
			end)
			bus:on("SELECT", function()
				call_count = call_count + 1
			end)

			bus:dispatch(Command.Select({ window_id = 1, position = { line = 1, col = 0 } }))

			assert.are.equal(2, call_count)
		end)

		it("dispatch does not call handlers for different command types", function()
			local bus = EventBus.new()
			local called = false

			bus:on("CLOSE_WINDOW", function()
				called = true
			end)

			bus:dispatch(Command.Select({ window_id = 1, position = { line = 1, col = 0 } }))

			assert.is_false(called)
		end)

		it("dispatch handles no handlers gracefully", function()
			local bus = EventBus.new()
			-- Should not throw
			bus:dispatch(Command.CloseWindow({ window_id = 1 }))
		end)

		it("dispatch handles invalid command gracefully", function()
			local bus = EventBus.new()
			-- Should not throw
			bus:dispatch(nil)
			bus:dispatch({})
			bus:dispatch({ type = nil })
		end)

		it("handler errors are caught and logged", function()
			local bus = EventBus.new()
			local second_handler_called = false

			bus:on("SELECT", function()
				error("test error")
			end)
			bus:on("SELECT", function()
				second_handler_called = true
			end)

			-- Should not throw, and second handler should still be called
			bus:dispatch(Command.Select({ window_id = 1, position = { line = 1, col = 0 } }))

			assert.is_true(second_handler_called)
		end)
	end)

	describe("on validation", function()
		it("on requires non-empty string command_type", function()
			local bus = EventBus.new()
			assert.has_error(function()
				bus:on("", function() end)
			end)
			assert.has_error(function()
				bus:on(nil, function() end)
			end)
		end)

		it("on requires function handler", function()
			local bus = EventBus.new()
			assert.has_error(function()
				bus:on("SELECT", "not a function")
			end)
			assert.has_error(function()
				bus:on("SELECT", nil)
			end)
		end)
	end)

	describe("history", function()
		it("history records dispatched commands", function()
			local bus = EventBus.new()

			local cmd1 = Command.CloseWindow({ window_id = 1 })
			local cmd2 = Command.Select({ window_id = 2, position = { line = 1, col = 0 } })

			bus:dispatch(cmd1)
			bus:dispatch(cmd2)

			local history = bus:history()
			assert.are.equal(2, #history)
			assert.are.equal(cmd1, history[1])
			assert.are.equal(cmd2, history[2])
		end)

		it("history returns a copy (not the internal array)", function()
			local bus = EventBus.new()
			bus:dispatch(Command.CloseWindow({ window_id = 1 }))

			local history1 = bus:history()
			local history2 = bus:history()

			assert.are_not.equal(history1, history2)
			assert.are.same(history1, history2)
		end)

		it("history is empty initially", function()
			local bus = EventBus.new()
			local history = bus:history()
			assert.are.equal(0, #history)
		end)
	end)

	describe("backward compatibility", function()
		it("listen and trigger still work", function()
			local bus = EventBus.new()
			local called = false

			bus:listen("state_change", function()
				called = true
			end)

			bus:trigger("state_change")

			assert.is_true(called)
		end)

		it("clear removes all listeners including command handlers", function()
			local bus = EventBus.new()
			local command_called = false
			local event_called = false

			bus:on("SELECT", function()
				command_called = true
			end)
			bus:listen("state_change", function()
				event_called = true
			end)

			bus:clear()

			bus:dispatch(Command.Select({ window_id = 1, position = { line = 1, col = 0 } }))
			bus:trigger("state_change")

			assert.is_false(command_called)
			assert.is_false(event_called)
		end)

		it("clear resets history", function()
			local bus = EventBus.new()
			bus:dispatch(Command.CloseWindow({ window_id = 1 }))
			assert.are.equal(1, #bus:history())

			bus:clear()
			assert.are.equal(0, #bus:history())
		end)
	end)
end)
