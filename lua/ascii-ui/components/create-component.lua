local FiberNode = require("ascii-ui.fibernode")
local Renderer = require("ascii-ui.renderer")
local is_callable = require("ascii-ui.utils.is_callable")
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

--- @alias ascii-ui.TemplateString string

--- Crea un componente personalizado y lo registra
--- @generic ascii-ui.ComponentClosure, T
--- @param name string Nombre del componente
--- @param functional_component fun(props: T): ascii-ui.FiberNode[] | ascii-ui.TemplateString
--- @param types? table<string, ascii-ui.PropsType> Tipos de los props del componente
--- @return fun(props: T): ascii-ui.ComponentClosure component_closure (El closure que renderiza el componente)
local function createComponent(name, functional_component, types)
	types = types or {}
	-- Validar que el nombre sea único
	if Renderer.component_tags[name] then
		logger.error(("El componente con nombre '%s' ya está registrado."):format(name))
	end

	-- Generar la pseudofunción del componente
	local component_function = setmetatable({}, {
		__is_a_component = true,
		__call = function(_, ...)
			local closure_id = tostring({})
			logger.debug("Creating closure for component '%s' with id %s", name, closure_id)
			local args = { ... }
			local factory, props

			if #args == 1 and type(args[1]) == "table" then
				props = from_function_prop(args[1], types)
				validate_props(props, types)
				function factory()
					-- dentro del workLoop, currentFiber ya está seteado
					return function()
						return functional_component(props)
					end
				end
			else
				factory = function()
					return function()
						return functional_component(unpack(args))
					end
				end
			end

			local closure = memoize(factory, { closure_id = closure_id, props = props })

			return {
				FiberNode.new({
					tag = "PLACEMENT",
					type = name,
					props = props or args,
					closure = closure,
				}),
			}
		end,
	})

	if not Renderer.component_tags[name] then
		Renderer.component_tags[name] = component_function
	end

	return component_function
end

return createComponent
