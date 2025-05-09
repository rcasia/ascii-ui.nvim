local Element = require("ascii-ui.buffer.element")
local createComponent = require("ascii-ui.components.functional-component")

---@alias ascii-ui.BoxProps { width: integer, height: integer, content: string }

---@param props ascii-ui.BoxProps
local function Box(props)
	props = props or {}
	props.width = props.width or 15
	props.height = props.height or 3
	props.content = props.content or ""
	local config = props.__config or require("ascii-ui.config")
	-- TODO: merge custom config with default

	return function()
		local cc = config.characters
		local width = props.width

		local output = {}
		local vertical_space = (props.height / 2)
		local upper_vertical_space = math.floor(vertical_space)
		local lower_vertical_space = math.ceil(vertical_space)
		local space = cc.vertical .. (" "):rep(width - 2) .. cc.vertical

		output[#output + 1] = cc.top_left .. (cc.horizontal):rep(width - 2) .. cc.top_right
		for _ = 1, upper_vertical_space - 1 do
			output[#output + 1] = space
		end

		if type(props.content) == "string" then
			local text = props.content
			local side_spaces = (width - #text - 2) / 2
			local left_spaces = math.ceil(side_spaces)
			local right_spaces = math.floor(side_spaces)
			output[#output + 1] = cc.vertical
				.. (" "):rep(left_spaces)
				.. text
				.. (" "):rep(right_spaces)
				.. cc.vertical
		else
			error("Not implemented")
		end

		for _ = 1, lower_vertical_space - 2 do
			output[#output + 1] = space
		end
		output[#output + 1] = cc.bottom_left .. (cc.horizontal):rep(width - 2) .. cc.bottom_right

		-- break into lines

		return vim.iter(output)
			:map(function(line)
				return Element:new(line):wrap()
			end)
			:totable()
	end
end

return createComponent("Box", Box)
