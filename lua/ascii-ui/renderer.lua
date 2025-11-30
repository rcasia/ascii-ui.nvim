local FiberNode = require("ascii-ui.fibernode")
local dom = require("ascii-ui.lib.dom-handler")
local fiber = require("ascii-ui.fiber")
local is_callable = require("ascii-ui.utils.is_callable")
local logger = require("ascii-ui.logger")
local xml = require("ascii-ui.lib.xml2lua")

---@class ascii-ui.Renderer
local Renderer = {}

Renderer.component_tags = {}

--- @return ascii-ui.Renderer
function Renderer:new()
	local state = {}

	setmetatable(state, self)
	self.__index = self

	return state
end

---@param renderable string | fun(): ascii-ui.FiberNode[]
---@return ascii-ui.Buffer
---@return ascii-ui.FiberNode?
function Renderer:render(renderable)
	if is_callable(renderable) then
		local result = fiber.render(renderable)
		return result:get_buffer(), result
	end

	if type(renderable) == "string" then
		local fibernodes = self:render_xml(renderable)
		local createComponent = require("ascii-ui.components.create-component")
		local Component = createComponent("innerxml", function()
			return function()
				return fibernodes
			end
		end)

		local result = fiber.render(Component)
		return result:get_buffer(), result
	end

	error("Cannot render: " .. vim.inspect(renderable))
end

--- @return ascii-ui.FiberNode[]
function Renderer:render_by_tag(tag_name, props, children)
	logger.info("Rendering tag: " .. tag_name)
	local instance
	if tag_name == "Column" then
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

		instance = Component(props)
	end

	if is_callable(instance) then
		return instance
	end

	if FiberNode.is_node(instance) then
		return instance
	end

	error("not expected. found: " .. vim.inspect(instance))
end

--- @param xml_content string
--- @return ascii-ui.FiberNode[]
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

	return component
end

return Renderer
