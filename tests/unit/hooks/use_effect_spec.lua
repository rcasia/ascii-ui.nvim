pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local Element = require("ascii-ui.buffer.element")
local ui = require("ascii-ui")
local useEffect = require("ascii-ui.hooks.use_effect")

describe("useEffect", function()
	it("gets executed just once when no dependencies", function()
		local log = {}
		local use_state_log = {}
		local value, set_value
		local Component = ui.createComponent("C", function()
			return function()
				value, set_value = ui.hooks.useState(0)
				use_state_log[#use_state_log + 1] = "useState called with value: " .. tostring(value)
				useEffect(function()
					log[#log + 1] = "useEffect called"
				end, {})
				return { Element:new({ content = tostring(value) }):wrap() }
			end
		end)

		ui.mount(Component)

		set_value(1)
		set_value(2)
		set_value(3)
		vim.wait(1000, function()
			return #use_state_log > 1
		end)

		eq(log, { "useEffect called" })
	end)
end)
