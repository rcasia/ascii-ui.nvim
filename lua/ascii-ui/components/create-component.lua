local FiberNode = require("ascii-ui.fibernode")
local Renderer = require("ascii-ui.renderer")
local is_callable = require("ascii-ui.utils.is_callable")
local logger = require("ascii-ui.logger")
local memoize = require("ascii-ui.utils.memoize")

--- @alias ascii-ui.PropsType
---| "nil"
---| "number"
---| "string"
---| "boolean"
---| "table"
---| "function"

--- @class ascii-ui.LayoutHint
--- @field algorithm? string
--- @field direction? "row" | "column"
--- @field gap? integer
--- @field align? string

--- @class ascii-ui.ComponentMeta
--- @field props? table<string, ascii-ui.PropsType>
--- @field layout? ascii-ui.LayoutHint

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

--- Normalises the third argument of createComponent.
---
--- Accepts two shapes:
---   flat (legacy):  { key = "type", ... }
---   extended:       { props = { key = "type" }, layout = { direction = "row" } }
---
--- Always returns { types = table, layout = table|nil }.
---
--- @param meta table | nil
--- @return table types, ascii-ui.LayoutHint | nil layout
local function normalise_meta(meta)
	if meta == nil then
		return {}, nil
	end
	-- Extended form is detected by the presence of a `props` or `layout` key
	-- whose value is a table (not a PropsType string).
	if type(meta.props) == "table" or type(meta.layout) == "table" then
		return meta.props or {}, meta.layout or nil
	end
	-- Flat legacy form: the whole table is the prop-type map.
	return meta, nil
end

--- @alias ascii-ui.TemplateString string

--- @generic ascii-ui.ComponentClosure, T
--- @alias ascii-ui.SimpleComponentFunction fun(props: T): ascii-ui.FiberNode[]
---

-- - @generic P : table<string, any>
--- @alias ascii-ui.FunctionalComponent<P> fun(props?: P): ascii-ui.FiberNode

--- Crea un componente personalizado y lo registra
--- @generic ascii-ui.ComponentClosure, T
--- @param name string Nombre del componente
--- @param functional_component fun(props: T): ascii-ui.FiberNode[]
--- @param meta? table<string, ascii-ui.PropsType> | ascii-ui.ComponentMeta
--- @return ascii-ui.FunctionalComponent
---
--- @overload fun(functional_component: ascii-ui.SimpleComponentFunction): ascii-ui.FunctionalComponent
local function createComponent(name, functional_component, meta)
	local prop_types, layout_hint = normalise_meta(meta)

	local opts = {
		name = name,
		functional_component = functional_component,
		types = prop_types,
		layout = layout_hint,
	}

	if type(opts.name) == "function" then
		opts.functional_component = opts.name
		opts.name = "anonymous"
		opts.types = {}
		opts.layout = nil
	end

	-- Validar que el nombre sea único
	if Renderer.component_tags[opts.name] then
		logger.error(("El componente con nombre '%s' ya está registrado."):format(opts.name))
	end

	-- Generar la pseudofunción del componente
	local component_function = setmetatable({}, {
		__is_a_component = true,
		__call = function(_, ...)
			local closure_id = tostring({})
			logger.debug("Creating closure for component '%s' with id %s", name, closure_id)
			local _args = { ... }
			local factory, props

			if #_args == 1 and type(_args[1]) == "table" then
				props = _args[1] or {}
				validate_props(props, opts.types, opts.name)
				function factory()
					-- dentro del workLoop, currentFiber ya está seteado
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

	if not Renderer.component_tags[name] then
		Renderer.component_tags[name] = component_function
	end

	return component_function
end

return createComponent
