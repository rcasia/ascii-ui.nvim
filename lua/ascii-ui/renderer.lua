local Buffer = require("ascii-ui.buffer")
local dom = require("ascii-ui.lib.dom-handler")
local fiber = require("ascii-ui.fiber")
local is_callable = require("ascii-ui.utils.is_callable")
local logger = require("ascii-ui.logger")
local xml = require("ascii-ui.lib.xml2lua")

---@class ascii-ui.Renderer
--- @field config ascii-ui.Config
local Renderer = {}

Renderer.component_tags = {}

---@param config? { characters: { top_left: string, top_right: string,
--- bottom_left: string, bottom_right: string, horizontal: string, vertical: string } }
--- @return ascii-ui.Renderer
function Renderer:new(config)
	config = config or {}
	local state = {
		config = config,
	}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@param renderable string
---| fun(config: ascii-ui.Config): string
---| fun(config: ascii-ui.Config): ascii-ui.BufferLine[]
---| fun(config: ascii-ui.Config): fun(config: ascii-ui.Config):  ascii-ui.BufferLine[]
---@return ascii-ui.Buffer
---@return ascii-ui.FiberNode?
function Renderer:render(renderable)
	if type(renderable) == "string" then
		return self:render_xml(renderable)
	end
	if is_callable(renderable) then
		return fiber.render(renderable)
	end

	if type(renderable) == "function" then
		local rendered = renderable(self.config)

		if type(rendered) == "table" and vim.isarray(rendered) then
			return Buffer.new(unpack(rendered))
		end

		if type(rendered) == "string" then
			return self:render_xml(rendered)
		end

		return Buffer.new(unpack(rendered(self.config)))
	end

	error("Cannot render: " .. vim.inspect(renderable))
end

--- @return ascii-ui.BufferLine[]
function Renderer:render_by_tag(tag_name, props, children)
	logger.info("Rendering tag: " .. tag_name)
	local instance
	if tag_name == "Layout" then
		local child_components = vim.iter(children)
			:map(function(child)
				return self:render_by_tag(child._name, child._attr, child._children)
			end)
			:totable()

		local component = assert(self.component_tags[tag_name], "Component not found for tag: " .. tag_name)

		instance = component(unpack(child_components))
	else
		local Component = self.component_tags[tag_name]
		if not Component then
			error("Component not found for tag: " .. tag_name)
		end

		local XmlApp = require("ascii-ui").createComponent("XMlApp", function()
			return Component(props)
		end)
		instance = XmlApp
	end

	if is_callable(instance) then
		return instance
	end

	error("not expected")
end

--- @param xml_content string
--- @return ascii-ui.Buffer
function Renderer:render_xml(xml_content)
	--- @return XmlNode
	local function xml_parse(dsl)
		local _dom = vim.deepcopy(dom) -- NOTE: copy the dom object to avoid modifying the original
		local parser = xml.parser(_dom)
		parser:parse(dsl)
		return vim.deepcopy(_dom.root._children[3])
	end

	local result = xml_parse(xml_content)
	logger.info(vim.inspect(result))

	local tag_name = result._name

	local props = result._attr

	local component = self:render_by_tag(tag_name, props, result._children)

	return fiber.render(component)
end

return Renderer
