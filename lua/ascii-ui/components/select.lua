local Element = require("ascii-ui.buffer.element")
local highlights = require("ascii-ui.highlights")
local interation_type = require("ascii-ui.interaction_type")

local useState = require("ascii-ui.hooks.use_state")

---@alias ascii-ui.SelectComponentOpts { options: string[], title?: string, on_select? : fun(selected_option: string) }

---@class ascii-ui.SelectComponent.Option
---@field id integer
---@field name string

---@param option_names string[]
---@return ascii-ui.SelectComponent.Option[]
local function from(option_names)
	local id = 0
	local next_id = function()
		id = id + 1
		return id
	end
	return vim.iter(option_names)
		:map(function(name)
			---@type ascii-ui.SelectComponent.Option
			return { id = next_id(), name = name }
		end)
		:totable()
end

--- @param props ascii-ui.SelectComponentOpts
function Select(props)
	return function()
		local options, setOptions = useState(from(props.options))
		local first_option = options()[1]
		local selected_id, setSelectedId = useState(first_option.id)

		local bufferlines = vim.iter(options())
			:map(function(option)
				local content = ""
				local highlight

				if option.id == selected_id() then
					content = ("[x] %s"):format(option.name)
					highlight = highlights.SELECTION
				else
					content = ("[ ] %s"):format(option.name)
				end

				return Element:new(content, true, {
					[interation_type.SELECT] = function()
						setSelectedId(option.id)
					end,
				}, highlight)
			end)
			:map(function(element)
				return element:wrap()
			end)
			:totable()

		if vim.fn.empty(props.title) == 0 then
			table.insert(bufferlines, 1, Element:new(props.title):wrap())
		end
		return bufferlines
	end
end

return Select
