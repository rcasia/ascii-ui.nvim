local Buffer = require("ascii-ui.buffer")
---@class ascii-ui.Renderer
local Renderer = {}

---@param config { characters: { top_left: string, top_right: string,
--- bottom_left: string, bottom_right: string, horizontal: string, vertical: string } }
--- @return ascii-ui.Renderer
function Renderer:new(config)
	local state = {
		config = config,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@param component ascii-ui.Component | ascii-ui.BufferLine[]
---@return ascii-ui.Buffer
function Renderer:render(component)
	if vim.isarray(component) then
		return Buffer:new(unpack(component))
	end
	if type(component) == "function" then
		return Buffer:new(unpack(component()))
	end

	assert(component.render)

	return Buffer:new(unpack(component:render()))
end

return Renderer
