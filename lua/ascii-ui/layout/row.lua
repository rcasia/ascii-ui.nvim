local BufferLine = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")
local logger = require("ascii-ui.logger")

--- @param ... fun(): ascii-ui.BufferLine[]
--- @return fun(): ascii-ui.BufferLine[]
local function Row(...)
	local component_closures = { ... }

	vim.iter(component_closures):each(function(c)
		assert(
			type(c) == "function",
			"ui.layout.Row should recieve component closures. Recieved: " .. type(c) .. vim.inspect(component_closures)
		)
	end)

	return function()
		local bufferline = BufferLine:new()
		for i, component_closure in ipairs(component_closures) do
			bufferline:append(component_closure()[1], Element:new(" "))
		end
		return { bufferline }
	end
end

return createComponent("Layout", Row, {})
