pcall(require, "luacov")

---@class FiberNode
---@field type string
---@field props table
---@field child FiberNode|nil
---@field sibling FiberNode|nil
---@field return_fiber FiberNode|nil
---@field render function|nil
---@field hooks table
---@field effects table
---@field is_dirty boolean
local FiberNode = {}
FiberNode.__index = FiberNode

--- Creates a new FiberNode.
---@param fields table
---@return FiberNode
function FiberNode:new(fields)
	local node = setmetatable({}, FiberNode)
	node.type = fields.type
	node.props = fields.props or {}
	node.render = fields.render
	node.child = nil
	node.sibling = nil
	node.return_fiber = nil
	node.hooks = {}
	node.effects = {}
	node.is_dirty = false
	return node
end

--- Reconciles the children of a fiber node.
--- Processes the result of calling the render function and maps
--- the resulting nodes into a linked list of fiber nodes.
---@param fiber FiberNode
---@param elements table
local function reconcile_children(fiber, elements)
	local prev_sibling = nil

	if type(elements) ~= "table" then
		return
	end

	local function process_element(element)
		if element == nil then
			return
		end

		if type(element) ~= "table" then
			return
		end

		-- Check if this is a nested table of elements (not a fiber element)
		-- A fiber element has a 'type' field
		if element.type == nil then
			-- It's a nested table, process each item
			for _, sub_element in ipairs(element) do
				process_element(sub_element)
			end
			return
		end

		local child_fiber = FiberNode:new({
			type = element.type,
			props = element.props,
			render = element.render,
		})
		child_fiber.return_fiber = fiber

		if fiber.child == nil then
			fiber.child = child_fiber
		end

		if prev_sibling ~= nil then
			prev_sibling.sibling = child_fiber
		end

		prev_sibling = child_fiber
		return child_fiber
	end

	for _, element in ipairs(elements) do
		process_element(element)
	end
end

--- Performs work on a fiber node.
--- If the fiber is a component (has a render function), it calls the render function
--- and reconciles the children. Returns the next fiber to process.
---@param fiber FiberNode
---@return FiberNode|nil
local function perform_unit_of_work(fiber)
	if fiber.render ~= nil then
		local result = fiber.render(fiber.props)
		if type(result) == "table" then
			reconcile_children(fiber, result)
		end
	end

	if fiber.child ~= nil then
		return fiber.child
	end

	if fiber.sibling ~= nil then
		return fiber.sibling
	end

	local parent = fiber.return_fiber
	while parent ~= nil do
		if parent.sibling ~= nil then
			return parent.sibling
		end
		parent = parent.return_fiber
	end

	return nil
end

---@class Fiber
---@field render function
local Fiber = {}

--- Renders a component tree starting from a root render function.
--- Returns the root FiberNode of the rendered tree.
---@param render_fn function
---@return FiberNode
function Fiber.render(render_fn)
	local root = FiberNode:new({
		type = "root",
		props = {},
		render = render_fn,
	})

	local current_fiber = root
	while current_fiber ~= nil do
		current_fiber = perform_unit_of_work(current_fiber)
	end

	return root
end

return Fiber
