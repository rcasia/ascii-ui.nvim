local FiberNode = require("ascii-ui.fibernode")
local is_callable = require("ascii-ui.utils.is_callable")
local logger = require("ascii-ui.logger")
local memoize = require("ascii-ui.utils.memoize")

local component_tags = {}

-- Counter for generating unique closure IDs
local next_closure_id = 0
local function generate_closure_id()
	next_closure_id = next_closure_id + 1
	return string.format("closure_%d", next_closure_id)
end

--- @alias ascii-ui.PropsType
---| "nil"
---| "number"
---| "string"
---| "boolean"
---| "table"
---| "function"

--- @alias ascii-ui.ComponentOptions { name: string, functional_component: function, types: table<string, ascii-ui.PropsType>, layout: ascii-ui.Layout | nil }

--- @param props table<string, any>
--- @param types table<string, ascii-ui.PropsType>
--- @param component_name string
local function validate_props(props, types, component_name)
	vim.iter(types):each(function(key, indicated_type)
		local actual_prop_type = type(props[key])
		if actual_prop_type == "nil" then
			return
		end
		if indicated_type == "function" and actual_prop_type == "table" and is_callable(props[key]) then
			return
		end
		if actual_prop_type ~= indicated_type then
			error(
				("Invalid prop '%s' in <%s>: expected '%s', got '%s'."):format(
					key,
					component_name,
					indicated_type,
					actual_prop_type
				)
			)
		end
	end)
end

--- Normalizes the third argument of createComponent into a consistent format.
--- Supports both the legacy flat format and the new extended format.
--- @param name string
--- @param types_or_opts table<string, ascii-ui.PropsType> | { props?: table<string, ascii-ui.PropsType>, layout?: ascii-ui.Layout }
--- @return table<string, ascii-ui.PropsType> types
--- @return ascii-ui.Layout | nil layout
local function normalize_opts(types_or_opts)
	if types_or_opts == nil then
		return {}, nil
	end

	-- Check if it's the extended format (has 'props' or 'layout' keys)
	if types_or_opts.props or types_or_opts.layout then
		return types_or_opts.props or {}, types_or_opts.layout
	end

	-- Legacy flat format
	return types_or_opts, nil
end

--- @alias ascii-ui.TemplateString string

--- @generic ascii-ui.ComponentClosure, T
--- @alias ascii-ui.SimpleComponentFunction fun(props: T): ascii-ui.FiberNode[]
---

-- - @generic P : table<string, any>
--- @alias ascii-ui.FunctionalComponent<P> fun(props?: P): ascii-ui.FiberNode

--- Creates a custom component and registers it
--- @generic ascii-ui.ComponentClosure, T
--- @param name string Component name
--- @param functional_component fun(props: T): ascii-ui.FiberNode[]
--- @param types_or_opts? table<string, ascii-ui.PropsType> | { props?: table<string, ascii-ui.PropsType>, layout?: ascii-ui.Layout }
--- @return ascii-ui.FunctionalComponent
---
--- @overload fun(functional_component: ascii-ui.SimpleComponentFunction): ascii-ui.FunctionalComponent
local function createComponent(name, functional_component, types_or_opts)
	local types, layout = normalize_opts(types_or_opts)
	local opts = { name = name, functional_component = functional_component, types = types, layout = layout }

	if type(opts.name) == "function" then
		opts.functional_component = opts.name
		opts.name = "anonymous"
		opts.types = {}
		opts.layout = nil
	end

	-- Validate that the name is unique
	if component_tags[opts.name] then
		logger.error(("El componente con nombre '%s' ya está registrado."):format(opts.name))
	end

	-- Generate the component's pseudo-function
	local component_function = setmetatable({}, {
		__is_a_component = true,
		__call = function(_, ...)
			local closure_id = generate_closure_id()
			logger.debug("Creating closure for component '%s' with id %s", name, closure_id)
			local _args = { ... }
			local factory, props

			if #_args == 1 and type(_args[1]) == "table" then
				props = _args[1] or {}
				validate_props(props, opts.types, opts.name)
				function factory()
					-- inside the workLoop, currentFiber is already set
					return function()
						return opts.functional_component(props)
					end
				end
			else
				factory = function()
					return function()
						return opts.functional_component(unpack(_args))
					end
				end
			end

			local closure = memoize(factory, { closure_id = closure_id, props = props })

			return FiberNode.new({
				tag = "PLACEMENT",
				type = opts.name,
				props = props or _args,
				closure = closure,
				layout = opts.layout,
			})
		end,
	})

	if not component_tags[name] then
		component_tags[name] = component_function
	end

	return component_function
end

return createComponent
