pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Effect = require("ascii-ui.effect")

describe("Effect", function()
	it("can create an effect", function()
		local effect = Effect({
			fn = function()
				return function()
					-- cleanup function
				end
			end,
		})

		eq(effect.get_status(), "INITIAL")
	end)

	it("can run an effect", function()
		local invoked = false
		local effect = Effect({
			fn = function()
				invoked = true
				return function() end
			end,
		})

		effect.run()

		eq(effect.get_status(), "MOUNTED")
		eq(true, invoked)
	end)

	it("can run an cleanup after an effect", function()
		local invoked = {
			effect = false,
			cleanup = false,
		}
		local effect = Effect({
			fn = function()
				invoked.effect = true
				return function()
					invoked.cleanup = true
				end
			end,
		})

		effect.run()
		effect.cleanup()

		eq(effect.get_status(), "CLEANED_UP")
		eq(true, invoked.cleanup)
	end)
end)
