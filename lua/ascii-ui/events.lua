local logger = require("ascii-ui.logger")

--- @class ascii-ui.EventBus
--- @field private _listeners table<string, function[]>  Command-type handlers (new API)
--- @field private _history ascii-ui.Command[]  Dispatched command history
local EventBus = {}
EventBus.__index = EventBus

--- Creates a new, isolated EventBus instance.
--- Each call to `ascii-ui.mount` should create its own bus so that multiple
--- mounted UIs never share listeners.
--- @return ascii-ui.EventBus
function EventBus.new()
	local state = {
		_listeners = {},
		_history = {},
	}
	return setmetatable(state, EventBus)
end

--- @enum (key) ascii-ui.EventType
local _ = {
	state_change = "state.change",
	CursorMovedSouth = "CursorMovedSouth",
	CursorMovedNorth = "CursorMovedNorth",
	CursorMovedEast = "CursorMovedEast",
	CursorMovedWest = "CursorMovedWest",
}

--- @param ev_type ascii-ui.EventType
--- @param fn function
function EventBus:listen(ev_type, fn)
	self[ev_type] = self[ev_type] or {}
	table.insert(self[ev_type], fn)
end

--- @param ev_type ascii-ui.EventType
function EventBus:trigger(ev_type)
	if not self[ev_type] then
		return
	end
	logger.info("🔫 Triggering event: " .. ev_type .. " that has " .. #self[ev_type] .. " functions")

	for _, fn in ipairs(self[ev_type]) do
		local ok, err = pcall(fn)
		if not ok then
			logger.error("Error while executing event listener for [" .. ev_type .. "]: " .. err)
		end
	end
end

--- Dispatches a command through the bus.
---
--- The command is appended to `self._history` (immutable record) and then
--- all handlers registered for `command.type` via `on()` are invoked with
--- the command as their sole argument.
---
--- Handlers must NOT mutate the command table.
---
--- @param command ascii-ui.Command
function EventBus:dispatch(command)
	if not command or not command.type then
		logger.warn("dispatch called with invalid command (missing type)")
		return
	end

	-- Record in history (append-only; commands are immutable by convention)
	table.insert(self._history, command)

	logger.info("Dispatching command: %s", command.type)

	local handlers = self._listeners[command.type]
	if not handlers then
		logger.debug("No handlers registered for command type: %s", command.type)
		return
	end

	for _, handler in ipairs(handlers) do
		local ok, err = pcall(handler, command)
		if not ok then
			logger.error("Error while handling command [%s]: %s", command.type, err)
		end
	end
end

--- Registers a handler for a specific command type.
---
--- @param command_type ascii-ui.CommandType  The command type string (e.g. "CLOSE_WINDOW").
--- @param handler fun(command: ascii-ui.Command)  Handler invoked with the dispatched command.
function EventBus:on(command_type, handler)
	if type(command_type) ~= "string" or command_type == "" then
		error("EventBus:on: command_type must be a non-empty string")
	end
	if type(handler) ~= "function" then
		error("EventBus:on: handler must be a function")
	end

	self._listeners[command_type] = self._listeners[command_type] or {}
	table.insert(self._listeners[command_type], handler)
end

--- Returns a shallow copy of the command history.
--- @return ascii-ui.Command[]
function EventBus:history()
	local copy = {}
	for i, cmd in ipairs(self._history) do
		copy[i] = cmd
	end
	return copy
end

--- Removes all registered listeners from every event type.
function EventBus:clear()
	logger.info("Cleared all event listeners")
	for k in pairs(self) do
		self[k] = nil
	end
	self._listeners = {}
	self._history = {}
end

return EventBus
