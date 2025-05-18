local Renderer = require("ascii-ui.renderer")
local logger = require("ascii-ui.logger")
local memoize = require("ascii-ui.utils.memoize")

--- @generic T
--- @generic P : ascii-ui.ComponentProps
--- @alias ComponentClosure fun(): ascii-ui.BufferLine[]
--- @alias ascii-ui.ComponentProp<T> T | fun(): T
--- @alias ascii-ui.ComponentProps table<string, ascii-ui.ComponentProp<any>>
--- @alias ascii-ui.FunctionalComponent<P> fun(props: P): ComponentClosure

local components = {}

--- Crea un componente personalizado y lo registra
--- @generic ascii-ui.ComponentClosure
--- @param name string Nombre del componente
--- @param component_closure ascii-ui.ComponentClosure
--- @return ascii-ui.ComponentClosure component_closure (El closure que renderiza el componente)
local function createComponent(name, component_closure)
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
				factory = function()
					return component_closure(args[1])
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
