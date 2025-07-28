local BufferLine = require("ascii-ui.buffer.bufferline")
local createComponent = require("ascii-ui.components.create-component")

--- @param ... fun(): ascii-ui.BufferLine[]
--- @return fun(): ascii-ui.BufferLine[]
local function Column(...)
	local components = { ... }
	local component_closures = function()
		return vim.iter(components):flatten():totable()
	end

	return function()
		local output = {}
		for idx, component in ipairs(component_closures()) do
			if idx ~= 1 then
				output[#output + 1] = BufferLine.new()
			end
			output[#output + 1] = component
		end

		return output
	end
end

return createComponent("Layout", Column)
