--- ascii-ui.hooks.useState() *ascii-ui.hooks.useState()*

local EventListener = require("ascii-ui.events")
local FiberNode = require("ascii-ui.fibernode")
local fiber = require("ascii-ui.fiber")
local logger = require("ascii-ui.logger")
local metrics = require("ascii-ui.utils.metrics")

---
--- Provides local state management within a component.
--- Returns getter and setter functions for a value, triggering UI updates on change.
---
--- Example:
--- ```
--- local MyComponent = ui.createComponent("MyComponent", function()
---   local count, setCount = ui.hooks.useState(0)
---     return {
---       ui.components.Paragraph({ content = "Count: " .. count }),
---       ui.components.Button({
---         label = "Increment",
---         on_press = function() setCount(count + 1) end
---       })
---     }
--- end)
--- ```
---
--- @generic T
--- @param value T The initial state value.
--- @return T value A deep copy of the current state value.
--- @return fun(value: T | fun(value: T): T) setValue Sets the state to a new value and triggers a state change event.
local useState = function(value)
	local _fiber = assert(fiber.getCurrentFiber(), "cannot call useState out of context")

	assert(_fiber.root, "fiber should have root: " .. vim.inspect(_fiber))
	local idx = _fiber.hookIndex
	if _fiber.hooks[idx] == nil then
		_fiber.hooks[idx] = value
		logger.debug("🥊 Initializing state for %s at index %d with value: %s", _fiber.type, idx, vim.inspect(value))
	end
	local snapshot = _fiber.hooks[idx]

	local function get()
		return vim.deepcopy(snapshot) -- return a copy of the state to avoid mutation
	end

	local function set(value_param)
		metrics.inc("hooks.useState.set.calls")
		logger.debug("Metrics inner: " .. vim.inspect(metrics.all()))
		logger.debug("🥊 State change detected: (component: %s, state: %s)", _fiber.type, vim.inspect(value_param))

		local new_value
		if type(value_param) == "function" then
			new_value = value_param(_fiber.hooks[idx])
		else
			new_value = value_param
		end

		-- do nothing if the value is the same as before
		if new_value == _fiber.hooks[idx] then
			logger.debug("🥊 No change in state, skipping re-render")
			return
		else
			logger.debug("🥊 State changed from %s to %s", vim.inspect(_fiber.hooks[idx]), vim.inspect(new_value))
			_fiber.hooks[idx] = new_value
		end

		-- ⇲ 2) P1 – ejecuta cleanups de efectos con deps no-vacíos ------
		if _fiber.cleanups then
			for i, cu in ipairs(_fiber.cleanups) do
				local deps = _fiber.prevDeps[i]
				-- solo si deps existe y no está vacío
				if deps and #deps > 0 and type(cu) == "function" then
					cu() -- cleanup inmediato (mantiene valor viejo)
					_fiber.cleanups[i] = nil -- se reasignará en el nuevo render
					_fiber.prevDeps[i] = nil
				end
			end
		end

		local root = FiberNode.resetFrom(_fiber)
		vim.iter(_fiber:iter()):each(function(n)
			n.tag = "UPDATE"
		end)

		fiber.debugPrint(root)

		EventListener:trigger("state_change")
	end

	_fiber.hookIndex = idx + 1
	return get(), set
end

return useState
