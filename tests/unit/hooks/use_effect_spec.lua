pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local useEffect = require("ascii-ui.hooks.use_effect")

describe("useEffect", function()
	it("invokes function upon first call", function()
		local fn_invocations = 0
		local fn = function()
			fn_invocations = fn_invocations + 1
		end
		useEffect(fn)

		eq(1, fn_invocations)
	end)
end)
