local memoize = require("ascii-ui.utils.memoize")
local logger = require("ascii-ui.logger")

--- @generic T
--- @generic P : ascii-ui.ComponentProps
--- @alias ascii-ui.Renderable fun(): ascii-ui.BufferLine[]
--- @alias ascii-ui.ComponentProp<T> T | fun(): T
--- @alias ascii-ui.ComponentProps table<string, ascii-ui.ComponentProp<any>>
--- @alias ascii-ui.FunctionalComponent<P> fun(props: P): ascii-ui.Renderable

local components = {}

--- Crea un componente personalizado y lo registra
--- @generic T: function
--- @param name string Nombre del componente
--- @param renderFunction T
--- @param opts? { avoid_memoize: boolean}
--- @return T: function (El closure que renderiza el componente)
local function createComponent(name, renderFunction, opts)
	opts = opts or {}

	-- Validar que el nombre sea único
	if components[name] then
		logger.error(("El componente con nombre '%s' ya está registrado."):format(name))
	end

	-- Registro del componente con su renderFunction
	components[name] = {
		render = renderFunction,
	}

	-- Generar la pseudofunción del componente
	return setmetatable({}, {
		__call = function(_, props)
			local factory = function()
				return renderFunction(props)
			end

			if opts.avoid_memoize then
				return factory()
			end

			return memoize(factory, props)
		end,
	})
end

return createComponent
