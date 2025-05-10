pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local ui = require("ascii-ui")
local Buffer = require("ascii-ui.buffer")
local Element = require("ascii-ui.buffer.element")
local If = require("ascii-ui.components.if")

describe("If", function()
	local component = ui.createComponent("DummyComponent", function(props)
		props = props or {}
		local counter, setCounter = ui.hooks.useState(0)

		return function()
			setCounter(counter() + 1)
			return { Element:new((props.content or "dummy_render ") .. tostring(counter())):wrap() }
		end
	end)

	it("renders child component when condition is true", function()
		local if_component = If({
			condition = function()
				return true
			end,

			child = component,

			fallback = function() end,
		})

		---@return string
		local lines = function()
			return Buffer:new(unpack(if_component())):to_string()
		end
		eq([[dummy_render 1]], lines())
	end)

	it("renders empty when condition is false and there is no fallback", function()
		local if_component = If({
			condition = function()
				return false
			end,

			child = component,

			fallback = function() end,
		})

		---@return string
		local lines = function()
			return Buffer:new(unpack(if_component())):to_string()
		end
		eq([[]], lines())
	end)
end)
