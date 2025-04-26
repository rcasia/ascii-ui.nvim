local Component = require("ascii-ui.components.component")
local BufferLine = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")

---@class ascii-ui.Checkbox : ascii-ui.Component
---@field checked boolean
---@field label string
local Checkbox = {
	__name = "CheckboxComponent",
}

---@param opts? { checked?: boolean, label?: string }
---@return ascii-ui.Checkbox
function Checkbox:new(opts)
	opts = opts or {}
	opts.checked = opts.checked or false
	opts.label = opts.label or ""
	return Component:extend(self, opts)
end

function Checkbox:toggle()
	self.checked = not self.checked
end

function Checkbox:is_checked()
	return self.checked
end

---@return ascii-ui.BufferLine[]
function Checkbox:render()
	return { Element:new(("[%s] %s"):format(self.checked and "x" or " ", self.label)):wrap() }
end

return Checkbox
