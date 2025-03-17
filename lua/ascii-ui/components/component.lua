---@class ascii-ui.Component
---@private __susbcriptions any
local Component = {
	__subscriptions = {},
}

---@return ascii-ui.Component
---@param state table<string, any>
function Component:new(state)
	local proxy = {}
	setmetatable(proxy, self)
	self.__index = self
	self.__newindex = function()
		for _, subscription_fun in ipairs(self.__subscriptions) do
			subscription_fun()
		end
	end

	return proxy
end

---@param f fun()
function Component:subscribe(f)
	self.__subscriptions[#self.__subscriptions + 1] = f
end

return Component
