pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local useState = require("ascii-ui.hooks.use_state")

describe("useState", function()
	it("stores the state of an arbitrary value", function()
		local counter, setCounter = useState(0)

		eq(0, counter())
		setCounter(1)

		eq(1, counter())
	end)

	it("accepts taking a function	in the setter", function()
		local counter, setCounter = useState(0)

		eq(0, counter())
		setCounter(function(value)
			return value + 1
		end)
		eq(1, counter())
	end)

	it("does not take the initial value for mutation", function()
		local my_table = { a = "a" }
		local data, setData = useState(my_table)

		eq(my_table, data())

		setData({ b = "b" })
		eq({ a = "a" }, my_table)

		setData(function(value)
			value.b = "b"
			return value
		end)
		eq({ a = "a" }, my_table)
	end)
end)
