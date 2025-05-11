local xml = require("tests.util.xml2lua")
local dom = require("tests.util.dom-handler")
local logger = require("ascii-ui.logger")
local Buffer = require("ascii-ui.buffer")
---@class ascii-ui.Renderer
local Renderer = {}

Renderer.component_tags = {}

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

---@param renderable ascii-ui.Component | ascii-ui.BufferLine[] | string
---@return ascii-ui.Buffer
function Renderer:render(renderable)
	if type(renderable) == "string" then
		return self:render_xml(renderable)
	end
	if vim.isarray(renderable) then
		return Buffer:new(unpack(renderable))
	end
	if type(renderable) == "function" then
		return Buffer:new(unpack(renderable()))
	end

	assert(renderable.render)

	return Buffer:new(unpack(renderable:render()))
end

function Renderer:render_by_tag(tag_name, props)
	local component = self.component_tags[tag_name]
	if not component then
		error("Component not found for tag: " .. tag_name)
	end

	local instance = component(props)

	if type(instance) == "function" then
		return Buffer:new(unpack(instance()))
	end

	return Buffer:new(unpack(instance:render()))
end

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
	if tag_name == "Layout" then
		local sub_components = vim.self:render_by_tag("Layout", props)
	end

	return self:render_by_tag(tag_name, props)
end

return Renderer
