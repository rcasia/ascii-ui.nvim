local Renderer = require("ascii-ui.renderer")
local logger = require("ascii-ui.logger")
local memoize = require("ascii-ui.utils.memoize")

--- @generic T
--- @generic P : ascii-ui.ComponentProps
--- @alias ComponentClosure fun(): ascii-ui.BufferLine[]
--- @alias ascii-ui.ComponentProp<T> T | fun(): T
--- @alias ascii-ui.ComponentProps table<string, ascii-ui.ComponentProp<any>>
--- @alias ascii-ui.FunctionalComponent<P> fun(props: P): ComponentClosure

--- @alias ascii-ui.PropsType
---| "nil"
---| "number"
---| "string"
---| "boolean"
---| "table"
---| "function"

local function is_callable(obj)
	if type(obj) == "function" then
		return true
	elseif type(obj) == "table" then
		local mt = getmetatable(obj)
		return type(mt and mt.__call) == "function"
	else
		return false
	end
end
--- @param props table<string, any>
--- @param types table<string, ascii-ui.PropsType>
local function validate_props(props, types)
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
				("Invalid prop type for '%s'. Expected '%s', got '%s'."):format(key, indicated_type, actual_prop_type)
			)
		end
	end)
end

--- @param props table<string, any>
--- @param types table<string, ascii-ui.PropsType>
--- @return table<string, any>
local function from_function_prop(props, types)
	return vim.iter(types)
		:map(function(key, indicated_type)
			if indicated_type ~= "function" and type(props[key]) == "function" then
				return key, props[key]()
			end
			if indicated_type == "function" and type(props[key]) == "string" then
				logger.debug("Resolving function reference for key '%s': %s", key, props[key])
				local fn = assert(_G.ascii_ui_function_registry[props[key]], "Function not found: " .. props[key])
				return key, fn
			end
			return key, props[key]
		end)
		:fold({}, function(acc, key, value)
			acc[key] = value
			return acc
		end)
end

local components = {}

--- Crea un componente personalizado y lo registra
--- @generic ascii-ui.ComponentClosure, T
--- @param name string Nombre del componente
--- @param functional_component fun(props: T)
--- @param types table<string, ascii-ui.PropsType> Tipos de los props del componente
--- @return ascii-ui.ComponentClosure component_closure (El closure que renderiza el componente)
local function createComponent(name, functional_component, types)
	types = types or {}
	-- Validar que el nombre sea único
	if components[name] then
		logger.error(("El componente con nombre '%s' ya está registrado."):format(name))
	end

	-- Registro del componente con su renderFunction
	components[name] = {
		render = functional_component,
	}

	-- Generar la pseudofunción del componente
	local component_function = setmetatable({}, {
		__call = function(_, ...)
			local closure_id = tostring({})
			logger.debug("Creating closure for component '%s' with id %s", name, closure_id)
			local args = { ... }
			local factory

			if #args == 1 and type(args[1]) == "table" then
				local props = from_function_prop(args[1], types)
				validate_props(props, types)
				logger.debug(
					"Creating closure for component '%s' with id %s and props %s",
					name,
					closure_id,
					vim.inspect(props)
				)
				factory = function()
					return functional_component(props)
				end
			else
				factory = function()
					return functional_component(unpack(args))
				end
			end

			return memoize(factory, { chache_key = closure_id })
		end,
	})

	if not Renderer.component_tags[name] then
		Renderer.component_tags[name] = component_function
	end

	return component_function
end

return createComponent
