pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local EventListener = require("ascii-ui.events")
local useEffect = require("ascii-ui.hooks.use_effect")
local useState = require("ascii-ui.hooks.use_state")

describe("useEffect", function()
	it("invokes function upon first call", function()
		local fn_invocations = 0
		local fn = function()
			fn_invocations = fn_invocations + 1
		end
		useEffect(fn)

		eq(1, fn_invocations)
	end)

	it("invokes function every time observed values change", function()
		local value, setValue = useState("A")
		local fn_invocations = 0
		local fn = function()
			fn_invocations = fn_invocations + 1
		end

		useEffect(fn, { value })

		setValue("B")
		eq(2, fn_invocations)
	end)

	it("does not invoke function when a non observed value changes", function()
		local value, _ = useState("A")
		local _, setOtherValue = useState("A")
		local fn_invocations = 0
		local fn = function()
			fn_invocations = fn_invocations + 1
		end

		useEffect(fn, { value })

		setOtherValue("B")
		eq(1, fn_invocations)
	end)

	it("runs clean up function when dependencies change", function()
		local value, setValue = useState("A")
		local clean_up_invocations = 0
		useEffect(function()
			-- clean up function
			return function()
				clean_up_invocations = clean_up_invocations + 1
			end
		end, { value })

		setValue("B")
		setValue("C")
		eq(2, clean_up_invocations)
	end)

	it("runs clean up function on ui.close event", function()
		local clean_up_invocations = 0
		useEffect(function()
			-- clean up function
			return function()
				clean_up_invocations = clean_up_invocations + 1
			end
		end)

		EventListener:trigger("ui_close")
		eq(1, clean_up_invocations)
	end)
end)
