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

--- @param f fun(component: table, key: string, value: any)
function Component:subscribe(f)
	table.insert(self.__subscriptions, f)
end

return Component
