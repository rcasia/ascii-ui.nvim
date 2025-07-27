--- This is used for comparing props
--- It will exclude the functions from the comparison
--- @param t1 table
--- @param t2 table
--- @return boolean
local function props_are_equal(t1, t2)
	t1 = t1 or {}
	t2 = t2 or {}
	if t1 == t2 then
		return true
	end
	if type(t1) ~= "table" or type(t2) ~= "table" then
		return false
	end

	for k, v in pairs(t1) do
		if t2[k] ~= v and not props_are_equal(t2[k], v) then
			return false
		end
	end
	for k in pairs(t2) do
		if t1[k] == nil then
			return false
		end
	end

	return true
end

return props_are_equal
