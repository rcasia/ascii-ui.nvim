local logger = require("ascii-ui.logger")

--- @class ascii-ui.Events
local EventListenter = {}

--- @enum (key) ascii-ui.EventType
local EventType = {
	state_change = "state.change",
}

--- @param ev_type ascii-ui.EventType
--- @param fn function
function EventListenter:listen(ev_type, fn)
	self[ev_type] = self[ev_type] or {}

	table.insert(self[ev_type], fn)
end

--- @param ev_type ascii-ui.EventType
function EventListenter:trigger(ev_type)
	if not self[ev_type] then
		return
	end

	for _, fn in ipairs(self[ev_type]) do
		local ok, err = pcall(fn)
		if not ok then
			logger.error("Error while executing event listener " .. ev_type .. ": " .. err)
		end
	end
end

return EventListenter
