pcall(require, "luacov")
---@module "luassert"

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local Column = ui.layout.Column
local Row = ui.layout.Row
local useState = ui.hooks.useState
local useInterval = ui.hooks.useInterval

describe("useInterval", function()
	local useTimer_invocations = 0
	local useEffect_invocations = 0

	--- @return string current_time in HH:MM:SS format
	local function useTimer()
		local counter, set_counter = useState(0)
		assert(useTimer_invocations <= 100, "useTimer can only be called once per component render")
		useTimer_invocations = useTimer_invocations + 1

		local time, set_time = useState(tostring(os.date("%H:%M:%S")))

		useInterval(function()
			set_time(tostring(os.date("%H:%M:%S")))
			set_counter(counter + 1)
			useEffect_invocations = useEffect_invocations + 1
		end, 30)

		return time
	end

	it("does run just once", function()
		local App = ui.createComponent("App", function()
			local time = useTimer()
			return Column(
				Paragraph({ content = "These are some clocks!" }),
				--
				Row(Button({ label = time }), Button({ label = time }))
			)
		end)

		ui.mount(App)
		vim.wait(100, function()
			return false
		end)

		assert(
			useEffect_invocations >= 3,
			"useEffect should run at least 3 times after 100ms. Ran just " .. useEffect_invocations
		)
	end)
end)
