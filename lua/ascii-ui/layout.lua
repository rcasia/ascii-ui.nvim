local BufferLine = require("ascii-ui.buffer.bufferline")

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

function Layout:destroy()
	for _, component in ipairs(self.components) do
		component:destroy()
	end
end

function Layout:render()
	local bufferlines = {}
	for idx, component in ipairs(self.components) do
		if idx ~= 1 then
			bufferlines[#bufferlines + 1] = BufferLine:new()
		end
		vim.iter(component:render()):each(function(line)
			bufferlines[#bufferlines + 1] = line
		end)
	end

	return Buffer:new(unpack(vim.iter(bufferlines):totable()))
end

return Layout
