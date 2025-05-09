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

	-- TODO:retire this custom render
	if component.type == "box" then
		return Buffer.from_lines(self:render_box(component))
	end
	assert(component.render)

	if component.__name == "Layout" then
		return component:render()
	end
	return Buffer:new(unpack(component:render()))
end

---@param box ascii-ui.Box
function Renderer:render_box(box)
	local child = box:child()
	local cc = self.config.characters
	local width = box.props.width

	local output = {}
	local vertical_space = (box.props.height / 2)
	local upper_vertical_space = math.floor(vertical_space)
	local lower_vertical_space = math.ceil(vertical_space)
	local space = cc.vertical .. (" "):rep(width - 2) .. cc.vertical

	output[#output + 1] = cc.top_left .. (cc.horizontal):rep(width - 2) .. cc.top_right
	for _ = 1, upper_vertical_space - 1 do
		output[#output + 1] = space
	end

	if box:has_child() == false then
		output[#output + 1] = space
	elseif type(child) == "string" then
		local text = child
		local side_spaces = (width - #text - 2) / 2
		local left_spaces = math.ceil(side_spaces)
		local right_spaces = math.floor(side_spaces)
		output[#output + 1] = cc.vertical .. (" "):rep(left_spaces) .. text .. (" "):rep(right_spaces) .. cc.vertical
	else
		error("Not implemented")
	end

	for _ = 1, lower_vertical_space - 2 do
		output[#output + 1] = space
	end
	output[#output + 1] = cc.bottom_left .. (cc.horizontal):rep(width - 2) .. cc.bottom_right

	return output
end

return Renderer
