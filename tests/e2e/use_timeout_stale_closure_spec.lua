pcall(require, "luacov")
---@module "luassert"

local async = require("plenary.async")
local async_it = async.tests.it

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local useTimeout = ui.hooks.useTimeout
local useState = ui.hooks.useState
local testing_e2e = require("ascii-ui.testing.e2e")

describe("useTimeout stale closure bug - simple", function()
	async_it("callback sees updated state", function()
		local final_count = -1

		local App = ui.createComponent("App", function()
			local count, setCount = useState(0)

			useTimeout(function()
				-- This callback should see the latest count value
				if count < 3 then
					setCount(count + 1)
				end
			end, 50)

			-- Track final state
			final_count = count

			return { Paragraph({ content = "count=" .. count }) }
		end)

		local screen = testing_e2e.mount(App)

		-- Wait for the chain to complete
		local completed = vim.wait(2000, function()
			return final_count >= 3
		end, 50)

		assert.is_true(completed, "count should reach 3. Got: " .. final_count)
		assert.are.equal(3, final_count)

		-- Clean up
		screen:unmount()
	end)
end)
