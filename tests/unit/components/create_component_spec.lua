pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local Segment = require("ascii-ui.buffer.segment")
local renderer = require("ascii-ui.renderer"):new()
local ui = require("ascii-ui")

describe("ComponentCreator.createComponent", function()
	local DummyComponent = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return { Segment:new({ content = props.content, interactions = { on_select = props.on_select } }):wrap() }
	end, { content = "string", on_select = "function" })

	it("creates a component that can have nested nodes", function()
		local App1 = ui.createComponent("App1", function()
			return {
				DummyComponent({ content = "t-shirt" }),
			}
		end)

		local App2 = ui.createComponent("App2", function()
			return { {
				DummyComponent({ content = "t-shirt" }),
			} }
		end)

		eq(renderer:render(App1):to_lines(), renderer:render(App2):to_lines())
		eq({ "t-shirt" }, renderer:render(App1):to_lines())
	end)

	it("creates a component that can have nil nodes", function()
		local App1 = ui.createComponent("App1", function()
			return {
				DummyComponent({ content = "t-shirt" }),
			}
		end)

		local App2 = ui.createComponent("App2", function()
			return {
				nil,
				DummyComponent({ content = "t-shirt" }),
			}
		end)

		eq(renderer:render(App1):to_lines(), renderer:render(App2):to_lines())
		eq({ "t-shirt" }, renderer:render(App1):to_lines())
	end)

	it("creates a component that can take props either as function or its simple type", function()
		local App1 = ui.createComponent("App1", function()
			return DummyComponent({ content = "t-shirt" })
		end)

		local App2 = ui.createComponent("App2", function()
			return DummyComponent({
				content = function()
					return "t-shirt"
				end,
			})
		end)
		eq(renderer:render(App1):to_lines(), renderer:render(App2):to_lines())
	end)

	it("creates a component that can take functions and are not called on definition", function()
		local invocations = 0
		local App = ui.createComponent("App2", function()
			return DummyComponent({
				content = function()
					return "t-shirt"
				end,
				on_select = function()
					invocations = invocations + 1
				end,
			})
		end)

		renderer:render(App)
		eq(0, invocations)
	end)

	it("validates props on definition call", function()
		assert.error(function()
			DummyComponent({ content = 2 })
		end, "Invalid prop type for 'content'. Expected 'string', got 'number'.")
	end)
end)
