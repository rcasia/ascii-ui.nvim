local logger = require("ascii-ui.logger")

--- @class ascii-ui.Events
local EventListenter = {}

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
function EventListenter:listen(ev_type, fn)
	self[ev_type] = self[ev_type] or {}

	-- table.insert(self[ev_type], throttle(fn, 100))
	table.insert(self[ev_type], fn)
end

--- @param ev_type ascii-ui.EventType
function EventListenter:trigger(ev_type)
	logger.info("🔫 Triggering event: " .. ev_type)
	if not self[ev_type] then
		return
	end

	for _, fn in ipairs(self[ev_type]) do
		local ok, err = pcall(fn)
		if not ok then
			logger.error("Error while executing event listener for [" .. ev_type .. "]: " .. err)
		end
	end
end

function EventListenter:clear()
	logger.info("Cleared event listeners")
	self.state_change = nil
end

return EventListenter
