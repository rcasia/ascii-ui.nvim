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
	local children = box:children()
	local cc = self.config.characters
	if #children == 0 then
		local width = box.props.width
		local output = "\n"
		output = output .. cc.top_left
		output = output .. (cc.horizontal):rep(width - 2)
		output = output .. cc.top_right .. "\n"
		output = output .. cc.vertical
		output = output .. (" "):rep(width - 2)
		output = output .. cc.vertical .. "\n"
		output = output .. cc.bottom_left
		output = output .. (cc.horizontal):rep(width - 2)
		output = output .. cc.bottom_right .. "\n"

		return output
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
