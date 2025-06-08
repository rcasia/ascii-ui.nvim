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
local FiberNode = {}
FiberNode.__index = FiberNode

---Create a new FiberNode instance
---@param fields table<string, any>
---@return ascii-ui.FiberNode
function FiberNode.new(fields)
	fields = fields or {}
	local node = {
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
	return setmetatable(node, FiberNode)
end

--- @param fiber ascii-ui.RootFiberNode
--- @return ascii-ui.RootFiberNode
function FiberNode.resetFrom(fiber)
	fiber.hookIndex = 1
	fiber.effectIndex = 1
	fiber.hooks = fiber.hooks or {}

	return fiber
end
return FiberNode
