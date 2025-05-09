local memoize = require("ascii-ui.utils.memoize")
local logger = require("ascii-ui.logger")

--- @generic T
--- @generic P : ascii-ui.ComponentProps
--- @alias ascii-ui.Renderable fun(): ascii-ui.BufferLine[]
--- @alias ascii-ui.ComponentProp<T> T | fun(): T
--- @alias ascii-ui.ComponentProps table<string, ascii-ui.ComponentProp<any>>
--- @alias ascii-ui.FunctionalComponent<P> fun(props: P): ascii-ui.Renderable

local ComponentCreator = {}
ComponentCreator.components = {}

--- Crea un componente personalizado y lo registra
--- @param name string Nombre del componente
--- @param renderFunction ascii-ui.FunctionalComponent: table (La función que define el componente)
--- @return function: function (El closure que renderiza el componente)
function ComponentCreator.createComponent(name, renderFunction)
	-- Validar que el nombre sea único
	if ComponentCreator.components[name] then
		logger.error(("El componente con nombre '%s' ya está registrado."):format(name))
	end

	-- Registro del componente con su renderFunction
	ComponentCreator.components[name] = {
		render = renderFunction,
	}

	-- Generar la pseudofunción del componente
	return setmetatable({}, {
		__call = function(_, props)
			local factory = function()
				return renderFunction(props)
			end

			return memoize(factory, props)
		end,
	})
end

return ComponentCreator
