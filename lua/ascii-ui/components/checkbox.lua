local Component = require("ascii-ui.components.component")
local BufferLine = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")

---@class ascii-ui.Checkbox : ascii-ui.Component
local Checkbox = {}

---@param opts? { checked?: boolean, label?: string }
---@return ascii-ui.Checkbox
function Checkbox:new(opts)
	opts = opts or {}
	opts.checked = opts.checked or false
	opts.label = opts.label or ""
	opts.type = "checkbox"
	return Component:extend(self, opts)
end

function Checkbox:toggle()
	self.checked = not self.checked
end

function Checkbox:is_checked()
	return self.checked
end

---@return ascii-ui.BufferLines[]
function Checkbox:render()
	return { BufferLine:new(Element:new(("[%s] %s"):format(self.checked and "x" or " ", self.label))) }
end

return Checkbox
