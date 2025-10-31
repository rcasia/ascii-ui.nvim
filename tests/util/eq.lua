-- simple equality helper (no luassert needed)
local function eq(actual, expected)
	if not vim.deep_equal(actual, expected) then
		error(("Expected:\n%s\nBut got:\n%s"):format(vim.inspect(expected), vim.inspect(actual)), 2)
	end
end

return eq
