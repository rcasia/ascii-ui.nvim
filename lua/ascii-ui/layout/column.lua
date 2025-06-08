local BufferLine = require("ascii-ui.buffer.bufferline")
local createComponent = require("ascii-ui.components.functional-component")

--- @param ... fun(): ascii-ui.BufferLine[]
--- @return fun(): ascii-ui.BufferLine[]
local function Layout(...)
	local component_closures = { ... }

	vim.iter(component_closures):each(function(c)
		assert(
			type(c) == "function",
			"Layout should receive component closures. Recieved: " .. type(c) .. vim.inspect(component_closures)
		)
	end)

	--- @param config ascii-ui.Config
	return function(config)
		local bufferlines = {}
		for idx, component in ipairs(component_closures) do
			if idx ~= 1 then
				bufferlines[#bufferlines + 1] = BufferLine.new()
			end
			vim.iter(component(config)):each(function(line)
				bufferlines[#bufferlines + 1] = line
			end)
		end

		return bufferlines
	end
end

return createComponent("Layout", Layout, { avoid_memoize = true })
