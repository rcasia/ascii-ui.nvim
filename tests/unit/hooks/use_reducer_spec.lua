pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local useReducer = require("ascii-ui.hooks.use_reducer")

describe("useReducer", function()
	it("useReducer", function()
		local reducer = function(state, action)
			if action == "increment" then
				state = state + 1
			end

			return state
		end
		local counter, dispatch = useReducer(reducer, 0)

		eq(0, counter())

		dispatch("increment")
		eq(1, counter())
	end)
end)
