local Component = require("ascii-ui.components.component")
local Bufferline = require("ascii-ui.buffer.bufferline")
local Element = require("ascii-ui.buffer.element")
local highlights = require("ascii-ui.highlights")
local interation_type = require("ascii-ui.interaction_type")

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

---@class ascii-ui.SelectComponent : ascii-ui.Component
---@field options ascii-ui.SelectComponent.Option[]
---@field _index_selected integer
---@field title string
---@field on_change fun(self: ascii-ui.SelectComponent, f : fun(component: ascii-ui.SelectComponent, key: ascii-ui.SelectComponent.Fields, value: any))
local Select = {
	__name = "SelectComponent",
}

---@param opts ascii-ui.SelectComponentOpts
---@return ascii-ui.SelectComponent
function Select:new(opts)
	--- @enum (key) ascii-ui.SelectComponent.Fields
	local state = {
		title = opts.title or "",
		options = from(opts.options),
		_index_selected = 1,
	}
	local c = Component:extend(self, state)
	if type(opts.on_select) == "function" then
		c:on_select(opts.on_select)
	end
	return c
end

---@return string selected_option
function Select:selected()
	return self.options[self._index_selected].name
end

---@param index integer
---@return string selected_option
function Select:select_index(index)
	self._index_selected = index
	return self.options[self._index_selected].name
end

---@return string selected_option
function Select:select_next()
	if #self.options == self._index_selected then
		self._index_selected = 1
	else
		self._index_selected = self._index_selected + 1
	end
	return self.options[self._index_selected].name
end

--- @param f fun(selected_option: string)
function Select:on_select(f)
	self:on_change(function(component, key, value)
		if key ~= "_index_selected" then
			return
		end

		f(self:selected())
	end)
end

---@return ascii-ui.BufferLine[]
function Select:render()
	local selected_id = self.options[self._index_selected].id

	local bufferlines = vim.iter(self.options)
		:map(function(option)
			local content = ""
			local highlight

			if option.id == selected_id then
				content = ("[x] %s"):format(option.name)
				highlight = highlights.SELECTION
			else
				content = ("[ ] %s"):format(option.name)
			end

			return Element:new(content, true, {
				[interation_type.SELECT] = function()
					self:select_index(option.id)
				end,
			}, highlight)
		end)
		:map(function(element)
			return element:wrap()
		end)
		:totable()

	if vim.fn.empty(self.title) == 0 then
		table.insert(bufferlines, 1, Element:new(self.title):wrap())
	end
	return bufferlines
end

return Select
