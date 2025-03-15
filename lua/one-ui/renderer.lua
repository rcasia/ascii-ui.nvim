local Renderer = {}

function Renderer:new()
	local renderer = {}

	setmetatable(renderer, self)
	self.__index = self

	return renderer
end

---@param component one-ui.Checkbox
function Renderer:render(component)
	if component.type == "checkbox" then
		return self:render_checkbox(component)
	end
	if component.type == "box" then
		return self:render_box(component)
	end
end

function Renderer:render_checkbox(checkbox)
	if checkbox:is_checked() then
		return "[X]"
	end
	return "[ ]"
end

---@param box one-ui.Box
function Renderer:render_box(box)
	local children = box:children()
	if #children == 0 then
		return [[

┏━━━━━━━━━━━━━━━┓
┃               ┃
┗━━━━━━━━━━━━━━━┛
]]
	end

	if #children == 1 and type(children[1]) == "string" then
		return ([[

┏━━━━━━━━━━━━━━━┓
┃     %s    ┃
┗━━━━━━━━━━━━━━━┛
]]):format(children[1])
	end

	error("Not implemented")
end

return Renderer
