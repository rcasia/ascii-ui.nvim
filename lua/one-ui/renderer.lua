---@class one-ui.Renderer
local Renderer = {}

---@param config { characters: { top_left: string, top_right: string,
--- bottom_left: string, bottom_right: string, horizontal: string, vertical: string } }
function Renderer:new(config)
	local state = {
		config = config,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@param component one-ui.Checkbox
---@return string
function Renderer:render(component)
	if component.type == "checkbox" then
		return self:render_checkbox(component)
	end
	if component.type == "box" then
		return self:render_box(component)
	end

	error("Component type not supported")
end

function Renderer:render_checkbox(checkbox)
	if checkbox:is_checked() then
		return "[X]"
	end
	return "[ ]"
end

---@param box one-ui.Box
function Renderer:render_box(box)
	local child = box:child()
	local cc = self.config.characters
	local width = box.props.width

	local output = "\n"
	local vertical_space = (box.props.height / 2)
	local upper_vertical_space = math.floor(vertical_space)
	local lower_vertical_space = math.ceil(vertical_space)
	local space = cc.vertical .. (" "):rep(width - 2) .. cc.vertical .. "\n"

	output = output .. cc.top_left .. (cc.horizontal):rep(width - 2) .. cc.top_right .. "\n"
	for _ = 1, upper_vertical_space - 1 do
		output = output .. space
	end

	if box:has_child() == false then
		output = vim.iter({ output .. cc.vertical .. (" "):rep(width - 2) .. cc.vertical .. "\n" }):join("")
	elseif type(child) == "string" then
		local text = child
		local side_spaces = (width - #text - 2) / 2
		local left_spaces = math.ceil(side_spaces)
		local right_spaces = math.floor(side_spaces)
		output = output
			.. cc.vertical
			.. (" "):rep(left_spaces)
			.. text
			.. (" "):rep(right_spaces)
			.. cc.vertical
			.. "\n"
	else
		error("Not implemented")
	end

	for _ = 1, lower_vertical_space - 2 do
		output = output .. space
	end
	output = output .. cc.bottom_left .. (cc.horizontal):rep(width - 2) .. cc.bottom_right .. "\n"

	return output
end

return Renderer
