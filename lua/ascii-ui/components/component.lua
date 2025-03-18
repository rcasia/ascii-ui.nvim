---@class ascii-ui.Component
local Component = {
	__name = "BaseComponent",
}

--- @return ascii-ui.Component
function Component:new()
	local instance = {
		__subscriptions = {},
	}
	setmetatable(instance, {
		__index = self,
		__newindex = function(t, key, value)
			rawset(t, key, value)
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

---@generic T
--- @param custom_component T
--- @return T
function Component:extend(custom_component)
	local instance = self:new()
	for k, v in pairs(custom_component) do
		instance[k] = v
	end
	return instance
end

return Component
