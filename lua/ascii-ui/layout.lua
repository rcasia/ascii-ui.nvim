local Layout = {
	__name = "Layout",
}

local Component = require("ascii-ui.components.component")
local Buffer = require("ascii-ui.buffer.buffer")

function Layout:new(...)
	local components = { ... }
	local state = {
		components = components,
	}
	return Component:extend(self, state)
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
