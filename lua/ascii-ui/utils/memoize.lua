local M = {}

-- Global cache table for all components
local cache = {}

--- Generates a unique key based on a table
local function generateKey(tbl)
	return vim.inspect(tbl) -- Serializes the properties to generate a unique key
end

--- @param factory function
--- @param dependants table<string, any> Dependencies for memoization
--- @return function fn memoized closure
function M.memoize(factory, dependants)
	local key = generateKey(dependants)
	if not cache[key] then
		cache[key] = factory()
	end
	-- assert(type(cache[key]) == "function", "Expected a function to be returned from the factory")
	return function()
		return cache[key]
	end
end

return M.memoize
