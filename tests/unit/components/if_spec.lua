pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Buffer = require("ascii-ui.buffer")
local Element = require("ascii-ui.buffer.element")
local If = require("ascii-ui.components.if")
local ui = require("ascii-ui")

describe("If", function()
	local component = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return function()
			return { Element:new(props.content):wrap() }
		end
	end, { content = "string" })

	it("renders child component when condition is true", function()
		local if_component = If({
			condition = function()
				return true
			end,

			child = component({ content = "dummy_render" }),

			fallback = function() end,
		})

		---@return string
		local lines = function()
			return Buffer:new(unpack(if_component())):to_string()
		end
		eq([[dummy_render]], lines())
	end)

	it("renders empty when condition is false and there is no fallback", function()
		local if_component = If({
			condition = function()
				return false
			end,

			child = component({ content = "dummy_render" }),
		})

		---@return string
		local lines = function()
			return Buffer:new(unpack(if_component())):to_string()
		end
		eq([[]], lines())
	end)

	it("renders fallback when condition is false", function()
		local if_component = If({
			condition = function()
				return false
			end,

			child = component(),

			fallback = component({ content = "I am the fallback" }),
		})

		---@return string
		local lines = function()
			return Buffer:new(unpack(if_component())):to_string()
		end
		eq([[I am the fallback]], lines())
	end)
end)
