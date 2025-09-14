local BufferLine = require("ascii-ui.buffer.bufferline")
local Fibernode = require("ascii-ui.fibernode")
local createComponent = require("ascii-ui.components.create-component")

--- @param ... fun(): ascii-ui.BufferLine[]
--- @return fun(): ascii-ui.BufferLine[]
local function Column(...)
	local components = { ... }
	assert(Fibernode.is_node_list(components), "Column only accepts components as arguments")

	return function()
		local output = {}
		for idx, component in ipairs(components) do
			if idx ~= 1 then
				output[#output + 1] = BufferLine.new()
			end
			output[#output + 1] = component
		end

		return output
	end
end

return createComponent("Column", Column)
