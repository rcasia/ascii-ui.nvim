pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Input = require("ascii-ui.components.input")
local testing = require("ascii-ui.testing")
local ui = require("ascii-ui")

describe("Input", function()
	it("renders", function()
		eq("", testing.render(Input):toSnapshot())
	end)

	it("renders with initial value", function()
		local initial_value = "hello world!"
		local App = ui.createComponent("App", function()
			return Input({ value = initial_value })
		end)

		eq(initial_value, testing.render(App):toSnapshot())
	end)

	it("handles nil value gracefully", function()
		local App = ui.createComponent("App", function()
			return Input({ value = nil })
		end)

		eq("", testing.render(App):toSnapshot())
	end)

	it("renders with initial_value prop", function()
		local App = ui.createComponent("App", function()
			return Input({ initial_value = "test" })
		end)

		eq("test", testing.render(App):toSnapshot())
	end)

	it("masks password input", function()
		local App = ui.createComponent("App", function()
			return Input({ value = "secret", password = true })
		end)

		eq("******", testing.render(App):toSnapshot())
	end)

	it("shows placeholder when empty", function()
		local App = ui.createComponent("App", function()
			return Input({ value = "", placeholder = "Enter text..." })
		end)

		eq("Enter text...", testing.render(App):toSnapshot())
	end)

	it("does not show placeholder when value exists", function()
		local App = ui.createComponent("App", function()
			return Input({ value = "hello", placeholder = "Enter text..." })
		end)

		eq("hello", testing.render(App):toSnapshot())
	end)

	it("handles empty password without error", function()
		local App = ui.createComponent("App", function()
			return Input({ value = "", password = true })
		end)

		eq("", testing.render(App):toSnapshot())
	end)
end)
