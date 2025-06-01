pcall(require, "luacov")
---@module "luassert"

local memoize = require("ascii-ui.utils.memoize")

local eq = assert.are.same

describe("util.memoize", function()
	it("returns the same closure if the dependants are equal", function()
		local invocations_a = 0
		local dependants = { key = "value" }
		local invocations_b = 0
		local result_fn_a = memoize(function()
			return function()
				invocations_a = invocations_a + 1
			end
		end, dependants)
		local result_fn_b = memoize(function()
			return function()
				invocations_b = invocations_a + 1
			end
		end, dependants)

		result_fn_a()
		result_fn_b()

		eq(0, invocations_b, "Function should not be invoked due to different key")
		eq(2, invocations_a, "Function should only be invoked once due to memoization")
	end)
end)
