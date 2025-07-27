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

return is_callable
