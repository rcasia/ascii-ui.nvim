local Bufferline = require("ascii-ui.buffer.bufferline")
local is_callable = require("ascii-ui.utils.is_callable")
local logger = require("ascii-ui.logger")

--- @class ascii-ui.RootFiberNode : ascii-ui.FiberNode
--- @field pendingEffects? function[]
--- @field pendingCleanups? function[]
--- @field lastRendered? ascii-ui.Buffer

--- @class ascii-ui.FiberNode
--- @field private repeatingEffects? function[]
--- @field private pendingEffects? function[]
--- @field private pendingCleanups? function[]
--- @field type string
--- @field tag "PLACEMENT" | "UPDATE" | "NONE"
--- @field props table | nil
--- @field root? ascii-ui.RootFiberNode
--- @field parent? ascii-ui.FiberNode
--- @field sibling? ascii-ui.FiberNode
--- @field child? ascii-ui.FiberNode
--- @field hooks? any[]
--- @field hookIndex integer
--- @field cleanups? function[]
--- @field prevDeps any[]
--- @field effectIndex integer
--- @field closure fun(config?: ascii-ui.Config): ascii-ui.FiberNode[]
--- @field output? ascii-ui.FiberNode[]
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
		tag = fields.tag or "PLACEMENT",
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

--- Returns the next fiber node in a depth-first traversal of the fiber tree.
---
--- The traversal order is:
--- 1. First child (if any),
--- 2. Then the next sibling (if no children or after visiting children),
--- 3. Otherwise, ascend the tree to find the next available sibling.
---
--- It returns `nil` when it reaches the end of the tree.
---
--- @see ascii-ui.FiberNode.iter
---
--- @return ascii-ui.FiberNode | nil
function FiberNode:next()
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

--- Returns an iterator that traverses the fiber tree in depth-first order,
--- starting from the current node. The iteration visits each node once,
--- descending first into children, then moving to siblings, and finally backtracking
--- to ancestors until the entire subtree has been visited.
---
--- Example usage:
--- ```lua
--- for node in root:iter() do
---     print(node.type)
--- end
--- ```
---
--- @see ascii-ui.FiberNode.next
---
--- @return fun(): ascii-ui.FiberNode | nil
function FiberNode:iter()
	local current = self
	return function()
		local result = current
		if current then
			current = current:next()
		end
		return result
	end
end

--- Creates a shallow copy of the current FiberNode, intended to be used
--- during the diffing process. The clone includes only the fields relevant
--- for comparison and rendering reconciliation, not runtime state like
--- hooks or effects.
---
--- @return ascii-ui.FiberNode
function FiberNode:clone_for_diff()
	return FiberNode.new({
		type = self.type,
		props = vim.deepcopy(self.props),
		closure = self.closure,
		lines = self._line,
		hooks = self.hooks,
		output = self.output,
		child = self.child,
		sibling = self.sibling,
	})
end

function FiberNode:__tostring()
	local propsInfo = self.props and vim.inspect(self.props) or "nil"

	return string.format(
		--
		"FiberNode<type=%s, name=%s, props=%s>",
		self.type or "unknown",
		propsInfo
	)
end

function FiberNode:run_pending()
	if self.pendingCleanups and #self.pendingCleanups > 0 then
		vim.iter(self.pendingCleanups):each(function(cu)
			logger.debug("running pending cleanup for %s", self.type)
			cu()
		end)
	end
	self.pendingCleanups = {}

	if self.repeatingEffects and #self.repeatingEffects > 0 then
		vim.iter(self.repeatingEffects):each(function(reff)
			logger.debug("running repeating effect for %s", self.type)
			reff()
		end)
	end

	if self.pendingEffects and #self.pendingEffects > 0 then
		vim.iter(self.pendingEffects):each(function(eff)
			logger.debug("running pending effect for %s", self.type)
			eff()
		end)
	end
	self.pendingEffects = {}
end

--- @param eff function
--- @param eff_type "REPEATING" | "ONCE"
function FiberNode:add_effect(eff, eff_type)
	logger.debug("Adding effect for fiber %s", self.type)
	if eff_type == "ONCE" then
		self.pendingEffects[#self.pendingEffects + 1] = eff
	end
	if eff_type == "REPEATING" then
		logger.debug("this effect is repeating")
		self.repeatingEffects = self.repeatingEffects or {}
		self.repeatingEffects[self.effectIndex] = eff
	end
end

--- @param cu function
function FiberNode:add_cleanup(cu)
	logger.debug("Adding cleanup for fiber %s", self.type)
	self.pendingCleanups[#self.pendingCleanups + 1] = cu
end

return FiberNode
