local Segment = require("ascii-ui.buffer.segment")
local highlights = require("ascii-ui.highlights")
local interation_type = require("ascii-ui.interaction_type")
local logger = require("ascii-ui.logger")

local createComponent = require("ascii-ui.components.create-component")
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
local function Select(props)
	-- TODO: add useEffect to update options when props change
	local selected, setSelected = useState(1)
	local options, _ = useState(from(props.options))

	local bufferlines = vim.iter(options)
		:map(function(option)
			local content, highlight

			logger.debug("CONDITION: option.id == selected " .. tostring(option.id == selected))
			if option.id == selected then
				content = ("[x] %s"):format(option.name)
				highlight = highlights.SELECTION
			else
				content = ("[ ] %s"):format(option.name)
			end

			return Segment:new(content, true, {
				[interation_type.SELECT] = function()
					setSelected(option.id)
					if props.on_select then
						props.on_select(option.name)
					end
				end,
			}, highlight)
		end)
		:map(function(segment)
			return segment:wrap()
		end)
		:totable()

	if vim.fn.empty(props.title) == 0 then
		table.insert(bufferlines, 1, Segment:new(props.title):wrap())
	end
	return bufferlines
end

return createComponent("Select", Select, { options = "table", title = "string", on_select = "function" })
