--- @class ascii-ui.Layout : ascii-ui.Component
--- @field components ascii-ui.Component[]
local Layout = {
	__name = "Layout",
}

local Component = require("ascii-ui.components.component")
local Buffer = require("ascii-ui.buffer.buffer")

--- @param ... ascii-ui.Component
function Layout:new(...)
	local components = { ... }
	local state = {
		components = components,
	}
	return Component:extend(self, state)
end

--- @param cb fun(component: table, key: string, value: any)
function Layout:subscribe(cb)
	for _, component in ipairs(self.components) do
		component:subscribe(cb)
	end
end

function Layout:render()
	return Buffer:new(unpack(vim.iter(self.components)
		:map(function(component)
			return component:render()
		end)
		:flatten()
		:totable()))
end

return Layout
