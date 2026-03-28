pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local Segment = require("ascii-ui.buffer.segment")
local renderer = require("ascii-ui.renderer"):new()
local ui = require("ascii-ui")

describe("ui.createComponent", function()
	local DummyComponent = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return { Segment:new({ content = props.content, interactions = { on_select = props.on_select } }):wrap() }
	end, { content = "string", on_select = "function" })

	it("creates a component with diferent overloads", function()
		local expected_output = { "t-shirt" }

		-- Anonymous component without name
		do
			local AnonymousComponent = ui.createComponent(function()
				return {
					DummyComponent({ content = "t-shirt" }),
				}
			end)
			eq(expected_output, renderer:render(AnonymousComponent):to_lines())
		end

		-- Anonymous component with non typed props
		do
			local AnonymousComponent = ui.createComponent(function(props)
				return {
					DummyComponent({ content = props.content or "" }),
				}
			end)

			eq(
				expected_output,
				renderer
					:render(function()
						return AnonymousComponent({ content = "t-shirt" })
					end)
					:to_lines()
			)
		end

		-- Named component
		do
			local NamedComponent = ui.createComponent("NamedComponent", function()
				return {
					DummyComponent({ content = "t-shirt" }),
				}
			end)
			eq(expected_output, renderer:render(NamedComponent):to_lines())
		end

		-- Component with nested nodes
		do
			local NamedComponent = ui.createComponent("NamedComponent", function()
				return { {
					DummyComponent({ content = "t-shirt" }),
				} }
			end)
			eq(expected_output, renderer:render(NamedComponent):to_lines())
		end

		-- Component with empty places
		do
			local App2 = ui.createComponent("App2", function()
				return {
					nil,
					DummyComponent({ content = "t-shirt" }),
				}
			end)

			eq(expected_output, renderer:render(App2):to_lines())
		end

		-- Component that is used as a child of another component
		do
			local ParentComponent = ui.createComponent("ParentComponent", function()
				return {
					DummyComponent({ content = "t-shirt" }),
				}
			end)

			local ChildComponent = ui.createComponent("ChildComponent", function()
				return {
					ParentComponent(),
				}
			end)

			eq(expected_output, renderer:render(ChildComponent):to_lines())
		end
	end)

	it("validates props on definition call", function()
		assert.error(function()
			DummyComponent({ content = 2 })
		end, "Invalid prop type for 'content'. Expected 'string', got 'number'.")
	end)
end)
