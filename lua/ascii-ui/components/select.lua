local Element = require("ascii-ui.buffer.element")
local highlights = require("ascii-ui.highlights")
local interation_type = require("ascii-ui.interaction_type")

local createComponent = require("ascii-ui.components.functional-component")
local useReducer = require("ascii-ui.hooks.use_reducer")

---@alias ascii-ui.SelectComponentOpts { options: string[], title?: string, on_select? : fun(selected_option: string) }

---@class ascii-ui.SelectComponent.Option
---@field id integer
---@field name string
---@field selected boolean

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
			return { id = next_id(), name = name, selected = id == 1 }
		end)
		:totable()
end

--- @param props ascii-ui.SelectComponentOpts
local function Select(props)
	return function()
		local options, dispatch = useReducer(function(options, action)
			local new_options = options
			if action.type == "select" then
				new_options = vim.iter(options)
					:map(function(opt)
						return {
							id = opt.id,
							name = opt.name,
							selected = opt.id == action.params.id,
						}
					end)
					:totable()
			end
			return new_options
		end, from(props.options))

		local bufferlines = vim.iter(options())
			:map(function(option)
				local content, highlight

				if option.selected then
					content = ("[x] %s"):format(option.name)
					highlight = highlights.SELECTION
				else
					content = ("[ ] %s"):format(option.name)
				end

				return Element:new(content, true, {
					[interation_type.SELECT] = function()
						if props.on_select then
							props.on_select(option.name)
						end
						dispatch({ type = "select", params = { id = option.id } })
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

return createComponent("Select", Select, { options = "table", title = "string", on_select = "function" })
