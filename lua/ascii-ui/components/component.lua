---@class ascii-ui.Component
---@field render fun(): ascii-ui.BufferLine[]
local Component = {
	__name = "BaseComponent",
}

local last_incremental_id = 0
local function generate_id()
	last_incremental_id = last_incremental_id + 1
	return last_incremental_id
end

--- @param component_name? string
--- @return ascii-ui.Component
function Component:new(component_name)
	local id = generate_id()

	local instance = {
		__id = id,
		__subscriptions = {},
		__name = component_name or "BaseComponent",
		__state = {},
	}
	setmetatable(instance, {
		__index = self,
		__newindex = function(t, key, value)
			rawset(instance, key, value)
			for _, callback in ipairs(t.__subscriptions) do
				pcall(callback, t, key, value)
			end
		end,
	})

	---@cast instance ascii-ui.Component
	return instance
end

--- @generic T
--- @param custom_component T
--- @param props? table<string, any>
--- @return T
function Component:extend(custom_component, props)
	assert(custom_component.__name, "your custom_component has to have a __name field")

	props = props or {}
	local instance = self:new(custom_component.__name)
	setmetatable(instance, {
		__index = function(t, key)
			local i0 = rawget(t.__state, key)
			local i1 = rawget(Component, key)
			local i2 = props[key]
			local i3 = custom_component[key]

			if type(i3) == "boolean" or i3 ~= nil then
				return i3
			end
			if type(i0) == "boolean" or i0 ~= nil then
				return i0
			end
			if type(i1) == "boolean" or i1 ~= nil then
				return i1
			end
			if type(i2) == "boolean" or i2 ~= nil then
				return i2
			end
			return nil
		end,
		__newindex = function(t, key, value)
			rawset(t.__state, key, value)

			for i = #t.__subscriptions, 1, -1 do -- iterating in reverse to be able to remove elements
				local callback = t.__subscriptions[i]
				local status_ok, err = pcall(callback, t, key, value)
				if not status_ok then
					table.remove(t.__subscriptions, i) -- removes item and compacts table to be array like
					print("Error in subscription callback: " .. err)
				end
			end
		end,
	})
	return instance
end

--- Adds a callback to be called when a property changes.
--- Cleared either when:
---  - the callback function fails
---  - the component is destroyed
---
--- @see Component.destroy
--- @see Component.clear_subscriptions
---
--- @param cb fun(component: table, key: string, value: any)
function Component:on_change(cb)
	table.insert(self.__subscriptions, cb)
end

function Component:clear_subscriptions()
	self.__subscriptions = {}
end

function Component:destroy()
	self:clear_subscriptions()
end

return Component
