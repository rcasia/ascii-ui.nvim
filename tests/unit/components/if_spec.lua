pcall(require, "luacov")
local assert = require("luassert")

local eq = assert.are.same

local Element = require("ascii-ui.buffer.element")
local If = require("ascii-ui.components.if")
local renderer = require("ascii-ui.renderer"):new()
local ui = require("ascii-ui")

describe("If", function()
	local component = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return function()
			return { Element:new(props.content):wrap() }
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
