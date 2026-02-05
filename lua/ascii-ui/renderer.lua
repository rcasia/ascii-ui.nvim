local fiber = require("ascii-ui.fiber")
local is_callable = require("ascii-ui.utils.is_callable")

---@class ascii-ui.Renderer
local Renderer = {}

Renderer.component_tags = {}

--- @return ascii-ui.Renderer
function Renderer:new()
	local state = {}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@param renderable string | fun(): ascii-ui.FiberNode[]
---@return ascii-ui.Buffer
---@return ascii-ui.FiberNode?
function Renderer:render(renderable)
	if is_callable(renderable) then
		local result = fiber.render(renderable)
		return result:get_buffer(), result
	end

	error("Cannot render: " .. vim.inspect(renderable))
end

return Renderer
