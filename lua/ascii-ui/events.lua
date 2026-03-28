local logger = require("ascii-ui.logger")

--- @class ascii-ui.EventBus
local EventBus = {}
EventBus.__index = EventBus

--- Creates a new, isolated EventBus instance.
--- Each call to `ascii-ui.mount` should create its own bus so that multiple
--- mounted UIs never share listeners.
--- @return ascii-ui.EventBus
function EventBus.new()
	return setmetatable({}, EventBus)
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

--- Removes all registered listeners from every event type.
function EventBus:clear()
	logger.info("Cleared all event listeners")
	for k in pairs(self) do
		self[k] = nil
	end
end

return EventBus
