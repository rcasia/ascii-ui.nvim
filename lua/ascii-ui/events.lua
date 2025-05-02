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
		fn()
	end
end

return EventListenter
