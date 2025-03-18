---@class ascii-ui.Component
local Component = {
	__name = "BaseComponent",
	__subscriptions = {},
}

--- @return ascii-ui.Component
function Component:new()
	local proxy = {}
	setmetatable(proxy, self)
	self.__index = self
	self.__newindex = function(t, key, value)
		rawset(t, key, value)
		for _, subscription_fun in ipairs(t.__subscriptions) do
			subscription_fun(t, key, value)
		end
	end
	return proxy
end

---@generic T
---@param custom_component T
function Component:extend(custom_component)
	setmetatable(custom_component, self)
	custom_component.__index = function(t, key)
		return rawget(custom_component, key) or self[key]
	end
	custom_component.__newindex = self.__newindex
	return custom_component
end

--- @param f fun(component: table, key: string, value: any)
function Component:subscribe(f)
	table.insert(self.__subscriptions, f)
end

return Component
