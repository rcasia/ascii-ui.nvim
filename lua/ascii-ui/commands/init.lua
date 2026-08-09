--- Command constructors for the ascii-ui command pattern.
---
--- Commands are immutable data objects that describe user intents.
--- They are created via constructor functions (e.g. `Command.CloseWindow({...})`)
--- and dispatched through an `EventBus`. Handlers registered with `bus:on(type, fn)`
--- receive the command and execute the corresponding side effects.
---
--- **Immutability convention**: Once a command table is constructed, neither the
--- dispatcher nor any handler may mutate its fields. Handlers must treat commands
--- as read-only.
---
--- @class ascii-ui.Command
--- @field type ascii-ui.CommandType
local Command = {}

--- @enum ascii-ui.CommandType
local CommandTypes = {
	CLOSE_WINDOW = "CLOSE_WINDOW",
	MOVE_WINDOW = "MOVE_WINDOW",
	CURSOR_MOVE = "CURSOR_MOVE",
	SELECT = "SELECT",
	HOVER = "HOVER",
	INPUT = "INPUT",
	STATE_CHANGE = "STATE_CHANGE",
	MOUNT = "MOUNT",
	UNMOUNT = "UNMOUNT",
}

--- Creates a CLOSE_WINDOW command.
--- @param opts { window_id: integer }
--- @return ascii-ui.Command
function Command.CloseWindow(opts)
	return {
		type = CommandTypes.CLOSE_WINDOW,
		window_id = opts.window_id,
	}
end

--- Creates a MOVE_WINDOW command.
--- @param opts { window_id: integer, position: ascii-ui.Position }
--- @return ascii-ui.Command
function Command.MoveWindow(opts)
	return {
		type = CommandTypes.MOVE_WINDOW,
		window_id = opts.window_id,
		position = opts.position,
	}
end

--- Creates a CURSOR_MOVE command.
--- @param opts { direction: ascii-ui.CursorDirection, position: ascii-ui.Position }
--- @return ascii-ui.Command
function Command.CursorMove(opts)
	return {
		type = CommandTypes.CURSOR_MOVE,
		direction = opts.direction,
		position = opts.position,
	}
end

--- Creates a SELECT command.
--- @param opts { window_id: integer, position: ascii-ui.Position }
--- @return ascii-ui.Command
function Command.Select(opts)
	return {
		type = CommandTypes.SELECT,
		window_id = opts.window_id,
		position = opts.position,
	}
end

--- Creates a HOVER command.
--- @param opts { window_id: integer, position: ascii-ui.Position }
--- @return ascii-ui.Command
function Command.Hover(opts)
	return {
		type = CommandTypes.HOVER,
		window_id = opts.window_id,
		position = opts.position,
	}
end

--- Creates an INPUT command.
--- @param opts { window_id: integer, position: ascii-ui.Position, text: string }
--- @return ascii-ui.Command
function Command.Input(opts)
	return {
		type = CommandTypes.INPUT,
		window_id = opts.window_id,
		position = opts.position,
		text = opts.text,
	}
end

--- Creates a STATE_CHANGE command.
--- @param opts { prop: string, value: any }
--- @return ascii-ui.Command
function Command.StateChange(opts)
	return {
		type = CommandTypes.STATE_CHANGE,
		prop = opts.prop,
		value = opts.value,
	}
end

--- Creates a MOUNT command.
--- @param opts { component: ascii-ui.FunctionalComponent }
--- @return ascii-ui.Command
function Command.Mount(opts)
	return {
		type = CommandTypes.MOUNT,
		component = opts.component,
	}
end

--- Creates an UNMOUNT command.
--- @param opts { window_id: integer }
--- @return ascii-ui.Command
function Command.Unmount(opts)
	return {
		type = CommandTypes.UNMOUNT,
		window_id = opts.window_id,
	}
end

--- Expose command type constants for handler registration.
--- @type table<string, ascii-ui.CommandType>
Command.types = CommandTypes

return Command
