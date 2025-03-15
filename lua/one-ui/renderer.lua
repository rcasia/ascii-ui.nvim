local Renderer = {}

function Renderer:new()
	local renderer = {}

	setmetatable(renderer, self)
	self.__index = self

	return renderer
end

---@param component one-ui.Checkbox
function Renderer:render(component)
	if component:is_checked() then
		return "[X]"
	end
	return "[ ]"
end

return Renderer
