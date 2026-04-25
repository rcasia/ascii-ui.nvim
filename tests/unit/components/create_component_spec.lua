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
		local ok, err = pcall(function()
			DummyComponent({ content = 2 })
		end)
		assert.is_false(ok)
		assert.truthy(err:find("DummyComponent"), "error should mention the component name")
		assert.truthy(err:find("content"), "error should mention the invalid prop key")
		assert.truthy(err:find("string"), "error should mention the expected type")
		assert.truthy(err:find("number"), "error should mention the actual type")
	end)

	it("prop validation error includes component name", function()
		local Typed = ui.createComponent("Typed", function(props)
			return { require("ascii-ui.buffer.segment"):new({ content = props.label }):wrap() }
		end, { label = "string" })

		local ok, err = pcall(function()
			Typed({ label = 42 })
		end)

		assert.is_false(ok)
		assert.truthy(err:find("Typed"), "error should mention component name 'Typed'")
		assert.truthy(err:find("label"), "error should mention the invalid prop 'label'")
		assert.truthy(err:find("string"), "error should mention expected type 'string'")
		assert.truthy(err:find("number"), "error should mention actual type 'number'")
	end)

	-- NEW: extended third argument shape
	describe("extended third arg", function()
		-- backward compat: flat prop-type map still works exactly as before
		it("flat third arg still validates props", function()
			local Flat = ui.createComponent("FlatBackcompat", function(props)
				return { Segment:new({ content = props.text }):wrap() }
			end, { text = "string" })

			-- valid call works
			eq({ "hello" }, renderer:render(function()
				return Flat({ text = "hello" })
			end):to_lines())

			-- invalid prop still raises
			local ok, err = pcall(function()
				Flat({ text = 42 })
			end)
			assert.is_false(ok)
			assert.truthy(err:find("string"))
		end)

		-- extended form: { props = {...}, layout = {...} }
		-- the fiber should carry the layout metadata
		it("extended third arg stores layout on the fiber node", function()
			local fiber = require("ascii-ui.fiber")

			local WithLayout = ui.createComponent("WithLayout", function(props)
				return { Segment:new({ content = props.label }):wrap() }
			end, {
				props = { label = "string" },
				layout = { direction = "row" },
			})

			-- renders correctly
			eq({ "hello" }, renderer:render(function()
				return WithLayout({ label = "hello" })
			end):to_lines())

			-- fiber carries layout metadata
			local root = fiber.render(function()
				return WithLayout({ label = "hello" })
			end)
			local comp_fiber = root.child

			assert.is_not_nil(comp_fiber, "component should appear as child fiber")
			assert.is_not_nil(comp_fiber.layout, "fiber should have layout field")
			assert.are.equal("row", comp_fiber.layout.direction)
		end)

		-- extended form: prop validation still works under the new shape
		it("extended third arg still validates props", function()
			local WithLayout = ui.createComponent("WithLayoutTyped", function(props)
				return { Segment:new({ content = props.label }):wrap() }
			end, {
				props = { label = "string" },
				layout = { direction = "row" },
			})

			local ok, err = pcall(function()
				WithLayout({ label = 99 })
			end)
			assert.is_false(ok)
			assert.truthy(err:find("string"))
		end)
	end)
end)
