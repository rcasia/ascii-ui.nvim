local BufferLine = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local Layout = require("ascii-ui.layout")
local createComponent = require("ascii-ui.components.functional-component")
local logger = require("ascii-ui.logger")

--- @param bufferlines ascii-ui.BufferLine[]
--- @param other_bufferlines ascii-ui.BufferLine[]
--- @return ascii-ui.BufferLine[]
local function merge_bufferlines(bufferlines, other_bufferlines)
	local max_index = math.max(#bufferlines, #other_bufferlines)
	local max_bufferline_width = vim
		.iter(bufferlines)
		--- @param bufferline ascii-ui.BufferLine
		:map(function(bufferline)
			return bufferline:len()
		end)
		:fold(0, math.max)

	local merged_bufferlines = {}
	for i = 1, max_index, 1 do
		local left_bufferline = bufferlines[i] or BufferLine:new()
		local right_bufferline = other_bufferlines[i] or BufferLine:new()

		local spacing_cols_count = max_bufferline_width - left_bufferline:len() + 1

		merged_bufferlines[i] = left_bufferline:append(right_bufferline, Element:new((" "):rep(spacing_cols_count)))
	end

	logger.debug("merge_bufferlines: %s", vim.inspect(merged_bufferlines))
	return merged_bufferlines
end

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

		return vim.iter(component_closures)
			:map(function(component_closure)
				return Layout(component_closure)
			end)
			:map(function(layout_closure)
				return layout_closure()
			end)
			:fold({}, function(acc, curr)
				return merge_bufferlines(acc, curr)
			end)
	end
end

return createComponent("Layout", Row, {})
