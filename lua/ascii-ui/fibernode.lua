local Bufferline = require("ascii-ui.buffer.bufferline")
local is_callable = require("ascii-ui.utils.is_callable")

--- @class ascii-ui.RootFiberNode : ascii-ui.FiberNode
--- @field pendingEffects? function[]
--- @field lastRendered? ascii-ui.Buffer

--- @class ascii-ui.FiberNode
--- @field root? ascii-ui.RootFiberNode
--- @field parent? ascii-ui.FiberNode
--- @field sibling? ascii-ui.FiberNode
--- @field child? ascii-ui.FiberNode
--- @field hooks? any[]
--- @field hookIndex integer
--- @field cleanups? function[]
--- @field prevDeps any[]
--- @field effectIndex integer
--- @field closure fun(config?: ascii-ui.Config): ascii-ui.BufferLine | ascii-ui.FiberNode[]
--- @field output? ascii-ui.BufferLine | ascii-ui.FiberNode[]
--- @field private _line ascii-ui.BufferLine
local FiberNode = {}
FiberNode.__index = FiberNode

---Create a new FiberNode instance
---@param fields table<string, any>
---@return ascii-ui.FiberNode
function FiberNode.new(fields)
	fields = fields or {}
	local node = {
		_line = fields.lines,
		name = fields.name,
		type = fields.type or "Root",
		props = fields.props,
		closure = fields.closure,
		output = fields.output,
		root = fields.root,
		child = fields.child,
		sibling = fields.sibling,
		parent = fields.parent,
		hookIndex = fields.hookIndex or 1,
		hooks = fields.hooks or {},
		effects = fields.effects or {},
		effectIndex = fields.effectIndex or 1,
		pendingEffects = fields.pendingEffects or {},
		prevDeps = fields.prevDeps or {},
		cleanups = fields.cleanups or {},
	}

	--- @type ascii-ui.FiberNode
	return setmetatable(node, FiberNode)
end

function FiberNode:is_leaf()
	return not self.child and not self.closure
end

--- @return ascii-ui.BufferLine
function FiberNode:get_line()
	assert(self._line, "Tried to get line from fiber node that has no line")

	return self._line
end

--- @param fiber ascii-ui.RootFiberNode
--- @return ascii-ui.RootFiberNode
function FiberNode.resetFrom(fiber)
	fiber.hookIndex = 1
	fiber.effectIndex = 1
	fiber.hooks = fiber.hooks or {}

	return fiber
end

--- @return ascii-ui.FiberNode[] output
function FiberNode:unwrap_closure()
	-- unwrap fibernode from functions
	local limit = 10
	local current = 0

	local output = self.closure()

	while is_callable(output) do
		if current >= limit then
			error("Reached maximum unwrapping limit for fiber.output, stopping to prevent infinite loop")
		end
		current = current + 1
		output = output()
	end

	return vim.iter(output)
		:map(function(item)
			if Bufferline.is_bufferline(item) then --- @cast item ascii-ui.BufferLine
				return FiberNode.new({ lines = item })
			end
			return item
		end)
		:totable()

	-- return output
end

--- @return ascii-ui.FiberNode | nil
function FiberNode:next_fiber()
	if self.child then
		return self.child
	end
	local node = self
	while node do
		if node.sibling then
			return node.sibling
		end
		node = node.parent
	end
	return nil
end

return FiberNode
