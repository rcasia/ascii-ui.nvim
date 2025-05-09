local M = {}

-- Tabla de caché global para todos los componentes
local cache = {}

--- Genera una clave única basada en las propiedades
local function generateKey(props)
	return vim.inspect(props) -- Serializa las propiedades para generar una clave única
end

--- Memoiza un closure basado en sus propiedades
--- @param factory function Función que genera el closure
--- @param props table Propiedades del componente
--- @return function Memoized closure
function M.memoize(factory, props)
	local key = generateKey(props)
	if not cache[key] then
		cache[key] = factory()
	end
	assert(type(cache[key]) == "function", "Expected a function to be returned from the factory")
	return cache[key]
end

return M.memoize
