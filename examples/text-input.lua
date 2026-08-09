local ui = require("ascii-ui")
local Input = ui.components.Input
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState

local function App()
	-- Controlled input state
	local name, setName = useState("")
	local email, setEmail = useState("")

	-- Submit handler
	local on_submit = function(value)
		vim.notify("Submitted: " .. value, vim.log.levels.INFO)
	end

	-- Blur handler
	local on_blur = function(value)
		vim.notify("Blurred with value: " .. value, vim.log.levels.DEBUG)
	end

	return {
		Paragraph({ content = "=== Input Component Demo ===" }),
		Paragraph({ content = "" }),

		-- Controlled input with placeholder
		Paragraph({ content = "1. Name (controlled, placeholder):" }),
		Input({
			value = name,
			on_change = setName,
			placeholder = "Enter your name",
		}),
		Paragraph({ content = "" }),

		-- Controlled input with on_submit
		Paragraph({ content = "2. Email (controlled, on_submit):" }),
		Input({
			value = email,
			on_change = setEmail,
			placeholder = "Enter your email",
			on_submit = on_submit,
		}),
		Paragraph({ content = "" }),

		-- Uncontrolled input with initial_value
		Paragraph({ content = "3. Search (uncontrolled, initial_value):" }),
		Input({
			initial_value = "",
			placeholder = "Type to search...",
			on_submit = on_submit,
		}),
		Paragraph({ content = "" }),

		-- Password input
		Paragraph({ content = "4. Password (masked):" }),
		Input({
			password = true,
			placeholder = "Enter password",
			on_blur = on_blur,
		}),
		Paragraph({ content = "" }),

		-- Instructions
		Paragraph({
			content = "───────────────────────────────",
		}),
		Paragraph({ content = "Navigation: Tab/Shift+Tab between inputs" }),
		Paragraph({ content = "Edit: Press 'i' to enter insert mode" }),
		Paragraph({ content = "Submit: Press <CR> in insert mode" }),
		Paragraph({ content = "Exit: Press <Esc> to leave insert mode" }),
		Paragraph({ content = "Quit: Press 'q' to close window" }),
	}
end

ui.mount(ui.createComponent("App", App))
