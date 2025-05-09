local BufferLine = require("ascii-ui.buffer.bufferline")

--- @param ... fun(): ascii-ui.BufferLine[]
--- @return fun(): ascii-ui.BufferLine[]
local function Layout(...)
	local components = { ... }

	return function()
		local bufferlines = {}
		for idx, component in ipairs(components) do
			if idx ~= 1 then
				bufferlines[#bufferlines + 1] = BufferLine:new()
			end
			vim.iter(component()):each(function(line)
				bufferlines[#bufferlines + 1] = line
			end)
		end

		return bufferlines
	end
end

return Layout
