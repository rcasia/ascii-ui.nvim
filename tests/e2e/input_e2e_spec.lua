pcall(require, "luacov")
--- @module "luassert"

local ui = require("ascii-ui")
local it = require("plenary.async.tests").it
local testing_e2e = require("ascii-ui.testing.e2e")

describe("Input e2e", function()
	it("renders Input component with placeholder", function()
		local Input = ui.components.Input
		local App = ui.createComponent("App", function()
			return {
				Input({ placeholder = "Enter text" }),
			}
		end)

		local screen = testing_e2e.mount(App)
		assert(screen:waitForText("Enter text"))
		screen:unmount()
	end)

	it("renders Input component with initial value", function()
		local Input = ui.components.Input
		local App = ui.createComponent("App", function()
			return {
				Input({ value = "initial text" }),
			}
		end)

		local screen = testing_e2e.mount(App)
		assert(screen:waitForText("initial text"))
		screen:unmount()
	end)

	it("navigates to Input with j/k", function()
		local Input = ui.components.Input
		local Paragraph = ui.components.Paragraph
		local App = ui.createComponent("App", function()
			return {
				Paragraph({ content = "Label" }),
				Input({ placeholder = "Type here" }),
			}
		end)

		local screen = testing_e2e.mount(App)
		assert(screen:waitForText("Label"))

		-- Navigate down to Input
		screen:press("j")
		vim.wait(100)

		-- Should be on Input line (line 2, column 0)
		assert(screen:cursorIsAt(2, 0))

		screen:unmount()
	end)

	it("has 'i' keymap for insert mode", function()
		local Input = ui.components.Input
		local App = ui.createComponent("App", function()
			return {
				Input({ placeholder = "Type here" }),
			}
		end)

		local screen = testing_e2e.mount(App)
		assert(screen:waitForText("Type here"))

		-- Check that 'i' keymap is set
		local bufnr = vim.api.nvim_get_current_buf()
		local keymaps = vim.api.nvim_buf_get_keymap(bufnr, "n")
		local has_i = false
		for _, km in ipairs(keymaps) do
			if km.lhs == "i" then
				has_i = true
				break
			end
		end
		assert.is_true(has_i, "'i' keymap should be set")

		screen:unmount()
	end)
end)
