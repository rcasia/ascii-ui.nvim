---@class ascii-ui.Component
---@field render fun(): ascii-ui.BufferLine[]
local Component = {
	__name = "BaseComponent",
}

--- @return ascii-ui.Component
function Component:new()
	local instance = {
		__subscriptions = {},
		__name = "BaseComponent",
		__state = {},
	}
	setmetatable(instance, {
		__index = self,
		__newindex = function(t, key, value)
			print(vim.inspect({ key = key, value = value }))
			rawset(instance, key, value)
			for _, callback in ipairs(t.__subscriptions) do
				callback(t, key, value)
			end
		end,
	})
	return instance
end

--- @generic T
--- @param custom_component T
--- @param props? table<string, any>
--- @return T
function Component:extend(custom_component, props)
	props = props or {}
	local instance = self:new()
	setmetatable(instance, {
		__index = function(t, key)
			local i0 = rawget(t.__state, key)
			local i1 = rawget(Component, key)
			local i2 = props[key]
			local i3 = custom_component[key]

			if type(i0) == "boolean" or i0 ~= nil then
				return i0
			end
			if type(i1) == "boolean" or i1 ~= nil then
				return i1
			end
			if type(i2) == "boolean" or i2 ~= nil then
				return i2
			end
			if type(i3) == "boolean" or i3 ~= nil then
				return i3
			end
			return nil
		end,
		__newindex = function(t, key, value)
			rawset(t.__state, key, value)
			for _, callback in ipairs(t.__subscriptions) do
				callback(t, key, value)
			end
		end,
	})
	return instance
end

--- @param cb fun(component: table, key: string, value: any)
function Component:subscribe(cb)
	table.insert(self.__subscriptions, cb)
end

function Component:clear_subscriptions()
	self.__subscriptions = {}
end

return Component
