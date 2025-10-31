pcall(require, "luacov")
---@module "luassert"

local eq = require("tests.util.eq")
local useFunctionRegistry = require("ascii-ui.hooks.use_function_registry")

describe("useFunctionRegistry", function()
	it("useFunctionRegistry", function()
		local invocations = 0
		local fn_ref = useFunctionRegistry(function()
			invocations = invocations + 1
		end)

		eq(type(fn_ref), "string")

		local fn = _G.ascii_ui_function_registry[fn_ref]
		eq(type(fn), "function")

		fn()

		eq(invocations, 1)
	end)
end)
