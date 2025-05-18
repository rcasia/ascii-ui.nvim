pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local EventListener = require("ascii-ui.events")
local useReducer = require("ascii-ui.hooks.use_reducer")

describe("useReducer", function()
	it("just works", function()
		local reducer = function(state, action)
			if action.type == "increment" then
				state.value = state.value + 1
			end

			return state
		end
		local my_obj = { value = 0 }
		local counter, dispatch = useReducer(reducer, my_obj)

		eq(my_obj, counter())

		EventListener:listen("state_change", function()
			eq({ value = 1 }, counter())
		end)
		dispatch({ type = "increment" })
	end)
end)
