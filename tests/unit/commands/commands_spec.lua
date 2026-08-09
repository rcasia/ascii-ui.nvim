pcall(require, "luacov")

local Command = require("ascii-ui.commands")

describe("Command", function()
	describe("constructors", function()
		it("CloseWindow creates command with correct structure", function()
			local cmd = Command.CloseWindow({ window_id = 42 })
			assert.are.equal("CLOSE_WINDOW", cmd.type)
			assert.are.equal(42, cmd.window_id)
		end)

		it("MoveWindow creates command with correct structure", function()
			local pos = { line = 10, col = 20 }
			local cmd = Command.MoveWindow({ window_id = 1, position = pos })
			assert.are.equal("MOVE_WINDOW", cmd.type)
			assert.are.equal(1, cmd.window_id)
			assert.are.same(pos, cmd.position)
		end)

		it("CursorMove creates command with correct structure", function()
			local pos = { line = 5, col = 3 }
			local cmd = Command.CursorMove({ direction = "SOUTH", position = pos })
			assert.are.equal("CURSOR_MOVE", cmd.type)
			assert.are.equal("SOUTH", cmd.direction)
			assert.are.same(pos, cmd.position)
		end)

		it("Select creates command with correct structure", function()
			local pos = { line = 1, col = 0 }
			local cmd = Command.Select({ window_id = 2, position = pos })
			assert.are.equal("SELECT", cmd.type)
			assert.are.equal(2, cmd.window_id)
			assert.are.same(pos, cmd.position)
		end)

		it("Hover creates command with correct structure", function()
			local pos = { line = 3, col = 5 }
			local cmd = Command.Hover({ window_id = 3, position = pos })
			assert.are.equal("HOVER", cmd.type)
			assert.are.equal(3, cmd.window_id)
			assert.are.same(pos, cmd.position)
		end)

		it("Input creates command with correct structure", function()
			local pos = { line = 2, col = 1 }
			local cmd = Command.Input({ window_id = 4, position = pos, text = "hello" })
			assert.are.equal("INPUT", cmd.type)
			assert.are.equal(4, cmd.window_id)
			assert.are.same(pos, cmd.position)
			assert.are.equal("hello", cmd.text)
		end)

		it("StateChange creates command with correct structure", function()
			local cmd = Command.StateChange({ prop = "count", value = 42 })
			assert.are.equal("STATE_CHANGE", cmd.type)
			assert.are.equal("count", cmd.prop)
			assert.are.equal(42, cmd.value)
		end)

		it("Mount creates command with correct structure", function()
			local comp = function()
				return {}
			end
			local cmd = Command.Mount({ component = comp })
			assert.are.equal("MOUNT", cmd.type)
			assert.are.equal(comp, cmd.component)
		end)

		it("Unmount creates command with correct structure", function()
			local cmd = Command.Unmount({ window_id = 5 })
			assert.are.equal("UNMOUNT", cmd.type)
			assert.are.equal(5, cmd.window_id)
		end)
	end)

	describe("types", function()
		it("exposes command type constants", function()
			assert.are.equal("CLOSE_WINDOW", Command.types.CLOSE_WINDOW)
			assert.are.equal("MOVE_WINDOW", Command.types.MOVE_WINDOW)
			assert.are.equal("CURSOR_MOVE", Command.types.CURSOR_MOVE)
			assert.are.equal("SELECT", Command.types.SELECT)
			assert.are.equal("HOVER", Command.types.HOVER)
			assert.are.equal("INPUT", Command.types.INPUT)
			assert.are.equal("STATE_CHANGE", Command.types.STATE_CHANGE)
			assert.are.equal("MOUNT", Command.types.MOUNT)
			assert.are.equal("UNMOUNT", Command.types.UNMOUNT)
		end)
	end)

	describe("immutability convention", function()
		it("commands are plain tables (immutability by convention)", function()
			local cmd = Command.CloseWindow({ window_id = 1 })
			assert.are.equal("table", type(cmd))
			-- Commands are immutable by convention - handlers should not mutate them
			-- This test documents the convention but does not enforce it programmatically
		end)
	end)
end)
