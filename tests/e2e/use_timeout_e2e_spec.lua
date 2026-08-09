pcall(require, "luacov")
---@module "luassert"

local async = require("plenary.async")
local async_it = async.tests.it

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local useTimeout = ui.hooks.useTimeout
local testing_e2e = require("ascii-ui.testing.e2e")

describe("useTimeout", function()
	async_it("cleans up timers on unmount", function()
		local callback_called = false

		local App = ui.createComponent("App", function()
			useTimeout(function()
				callback_called = true
			end, 100)

			return { Paragraph({ content = "test" }) }
		end)

		local screen = testing_e2e.mount(App)

		-- Unmount immediately (before the 100ms timer fires)
		screen:unmount()

		-- Wait longer than the timer delay
		vim.wait(200, function()
			return false
		end)

		-- The callback should NOT have been called because the timer was cancelled
		assert.is_false(callback_called)
	end)

	async_it("fires callback when not unmounted", function()
		local callback_called = false

		local App = ui.createComponent("App", function()
			useTimeout(function()
				callback_called = true
			end, 50)

			return { Paragraph({ content = "test" }) }
		end)

		local screen = testing_e2e.mount(App)

		-- Wait for the timer to fire
		vim.wait(200, function()
			return callback_called
		end)

		assert.is_true(callback_called)

		-- Clean up
		screen:unmount()
	end)

	async_it("cleans up useInterval timers on unmount", function()
		local useInterval = ui.hooks.useInterval
		local call_count = 0

		local App = ui.createComponent("App", function()
			useInterval(function()
				call_count = call_count + 1
			end, 30)

			return { Paragraph({ content = "interval test" }) }
		end)

		local screen = testing_e2e.mount(App)

		-- Let it fire a couple times
		vim.wait(100, function()
			return call_count >= 2
		end)

		local count_before_unmount = call_count
		assert.is_true(count_before_unmount >= 2, "interval should have fired at least twice")

		-- Unmount
		screen:unmount()

		-- Wait and verify no more calls happen
		vim.wait(150, function()
			return false
		end)

		assert.are.equal(count_before_unmount, call_count)
	end)
end)
