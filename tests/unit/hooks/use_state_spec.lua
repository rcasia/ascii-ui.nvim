pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local useState = require("ascii-ui.hooks.use_state")

describe("useState", function()
	it("useState", function()
		local counter, setCounter = useState(0)

		eq(0, counter())
		setCounter(1)

		eq(1, counter())
	end)
end)
