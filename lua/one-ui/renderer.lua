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
	if #box:children() == 0 then
		return [[

┏━━━━━━━━━━━━━━━┓
┃               ┃
┗━━━━━━━━━━━━━━━┛
]]
	end

	return [[

┏━━━━━━━━━━━━━━━┓
┃     Hello!    ┃
┗━━━━━━━━━━━━━━━┛
]]
end

return Renderer
