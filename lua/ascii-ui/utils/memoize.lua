local M = {}

-- Tabla de caché global para todos los componentes
local cache = {}

--- Genera una clave única basada en una tabla
local function generateKey(tbl)
	return vim.inspect(tbl) -- Serializa las propiedades para generar una clave única
end

--- @param factory function
--- @param dependants table<string, any> Dependencies for memoization
--- @return function fn memoized closure
function M.memoize(factory, dependants)
	local key = generateKey(dependants)
	if not cache[key] then
		cache[key] = factory()
	end
	assert(type(cache[key]) == "function", "Expected a function to be returned from the factory")
	return cache[key]
end

return M.memoize
