local M = {}

function M.say_hi()
	print("hello world")
end

setmetatable(M, {
	__call = function(_, opts)
		opts = opts or {}
		return M
	end,
})

return M
