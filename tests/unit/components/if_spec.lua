pcall(require, "luacov")
---@module "luassert"

local eq = require("tests.util.eq")

local If = require("ascii-ui.components.if")
local Segment = require("ascii-ui.buffer.segment")
local renderer = require("ascii-ui.renderer"):new()
local ui = require("ascii-ui")

describe("If", function()
	local component = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return function()
			return { Segment:new(props.content):wrap() }
		end
	end, { content = "string" })

	it("renders child component when condition is true", function()
		local App = ui.createComponent("App", function()
			return If({
				condition = function()
					return true
				end,

				child = component({ content = "dummy_render" }),
			})
		end)

		eq([[dummy_render]], renderer:render(App):to_string())
	end)

	it("renders empty when condition is false and there is no fallback", function()
		local App = ui.createComponent("App", function()
			return If({
				condition = function()
					return false
				end,

				child = component({ content = "dummy_render" }),
			})
		end)

		eq([[]], renderer:render(App):to_string())
	end)

	it("renders fallback when condition is false", function()
		local App = ui.createComponent("App", function()
			return If({
				condition = function()
					return false
				end,

				child = component({ content = "dummy_render" }),

				fallback = component({ content = "I am the fallback" }),
			})
		end)

		eq([[I am the fallback]], renderer:render(App):to_string())
	end)
end)
