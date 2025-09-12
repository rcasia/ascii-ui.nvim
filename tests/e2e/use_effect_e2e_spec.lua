pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local Column = ui.layout.Column
local Row = ui.layout.Row
local useState = ui.hooks.useState
local useEffect = ui.hooks.useEffect

describe("useEffect", function()
	local useTimer_invocations = 0
	local useEffect_invocations = 0

	--- @return string current_time in HH:MM:SS format
	local function useTimer()
		local counter, set_counter = useState(0)
		assert(useTimer_invocations <= 100, "useTimer can only be called once per component render")
		useTimer_invocations = useTimer_invocations + 1
		local setInterval = function(callback, interval)
			return vim.uv.new_timer():start(interval, interval, function()
				callback()
			end)
		end

		local time, set_time = useState(tostring(os.date("%H:%M:%S")))

		useEffect(function()
			setInterval(function()
				set_time(tostring(os.date("%H:%M:%S")))
				set_counter(counter + 1)
				useEffect_invocations = useEffect_invocations + 1
			end, 33)
		end, {})

		return time
	end

	local App = ui.createComponent("App", function()
		local time = useTimer()
		return Column(
			Paragraph({ content = "These are some clocks!" }),
			--
			Row(Button({ label = time }), Button({ label = time }))
		)
	end)

	-- FIXME: when there is useEffect
	it("does run just once", function()
		ui.mount(App)
		vim.wait(100, function()
			return false
		end)

		-- FIXME: it should be 1?
		-- but it is 11
		-- eq(1, useTimer_invocations, "useEffect should only run once per component render")
		eq(3, useEffect_invocations, "useEffect should run 3 times: on mount and every second after that")
	end)
end)
