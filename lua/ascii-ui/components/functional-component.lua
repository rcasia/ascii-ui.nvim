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
---| "integer"
---| "string"
---| "boolean"
---| "table"
---| "function"

--- @param props table<string, any>
--- @param types table<string, ascii-ui.PropsType>
--- @return table<string, any>
local function from_function_prop(props, types)
	return vim.iter(types)
		:map(function(key, indicated_type)
			if indicated_type ~= "function" and type(props[key]) == "function" then
				return key, props[key]()
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
--- @param component_closure fun(props: T)
--- @param types table<string, ascii-ui.PropsType> Tipos de los props del componente
--- @return ascii-ui.ComponentClosure component_closure (El closure que renderiza el componente)
local function createComponent(name, component_closure, types)
	types = types or {}
	-- Validar que el nombre sea único
	if components[name] then
		logger.error(("El componente con nombre '%s' ya está registrado."):format(name))
	end

	-- Registro del componente con su renderFunction
	components[name] = {
		render = component_closure,
	}

	if not Renderer.component_tags[name] then
		Renderer.component_tags[name] = component_closure
	end

	-- Generar la pseudofunción del componente
	return setmetatable({}, {
		__call = function(_, ...)
			local closure_id = tostring({})
			logger.debug("Creating closure for component '%s' with id %s", name, closure_id)
			local args = { ... }
			local factory

			if #args == 1 and type(args[1]) == "table" then
				local props = from_function_prop(args[1], types)
				logger.debug(
					"Creating closure for component '%s' with id %s and props %s",
					name,
					closure_id,
					vim.inspect(props)
				)
				factory = function()
					return component_closure(props)
				end
			else
				factory = function()
					return component_closure(unpack(args))
				end
			end

			return memoize(factory, { chache_key = closure_id })
		end,
	})
end

return createComponent
