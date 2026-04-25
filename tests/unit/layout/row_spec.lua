pcall(require, "luacov")

local eq = assert.are.same

local Segment = require("ascii-ui.buffer.segment")
local renderer = require("ascii-ui.renderer"):new()
local ui = require("ascii-ui")

local Row = require("ascii-ui.layout.row")

describe("Row", function()
	local DummyComponent = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return function()
			return {
				Segment:new(props.content):wrap(),
				Segment:new(props.content):wrap(),
				Segment:new("smol txt"):wrap(),
			}
		end
	end, { content = "string" })

	it("should render components in a row", function()
		local App = ui.createComponent("DummyApp", function()
			return Row(
				DummyComponent({ content = "component 1" }),
				DummyComponent({ content = "component 2" }),
				DummyComponent({ content = "component 3" })
			)
		end)

		eq({
			"component 1 component 2 component 3",
			"component 1 component 2 component 3",
			"smol txt    smol txt    smol txt",
		}, renderer:render(App):to_lines())
	end)

	local AnotherComponent = ui.createComponent("DummyComponent", function(props)
		props = props or {}

		return function()
			return vim.iter(vim.fn.range(1, props.times))
				:map(function()
					return Segment:new(props.content):wrap()
				end)
				:totable()
			end
	end, { content = "string", times = "number" })

	it("should render components respecting the empty space on the left", function()
		local App = ui.createComponent("DummyApp", function()
			return Row(
				AnotherComponent({ content = "component 1", times = 1 }),
				AnotherComponent({ content = "component 2", times = 2 }),
				AnotherComponent({ content = "component 3", times = 3 })
			)
		end)

		eq({
			"component 1 component 2 component 3",
			"            component 2 component 3",
			"                        component 3",
		}, renderer:render(App):to_lines())
	end)

	-- NEW: layout descriptor contract
	-- Row({ children = {...} }) should expose layout metadata and
	-- its children as real child/sibling fibers in the tree,
	-- so the layout pass can place them without running the render closure.
	describe("layout descriptor", function()
		it("Row fiber should carry layout.direction = 'row'", function()
			local fiber = require("ascii-ui.fiber")

			local App = ui.createComponent("DescriptorApp", function()
				return Row({
					children = {
						DummyComponent({ content = "left" }),
						DummyComponent({ content = "right" }),
					},
				})
			end)

			local root = fiber.render(App)
			local row_fiber = root.child

			assert.is_not_nil(row_fiber, "Row should be a child fiber of App")
			assert.are.equal("Row", row_fiber.type)
			assert.is_not_nil(row_fiber.layout, "Row fiber should have a layout field")
			assert.are.equal("row", row_fiber.layout.direction)
		end)

		it("Row children should be materialized as child/sibling fibers in the tree", function()
			local fiber = require("ascii-ui.fiber")

			local App = ui.createComponent("ChildrenApp", function()
				return Row({
					children = {
						DummyComponent({ content = "left" }),
						DummyComponent({ content = "right" }),
					},
				})
			end)

			local root = fiber.render(App)
			local row_fiber = root.child

			assert.is_not_nil(row_fiber.child, "Row should have a first child fiber")
			assert.is_not_nil(row_fiber.child.sibling, "First child should have a sibling")
			assert.is_nil(row_fiber.child.sibling.sibling, "Should be exactly two children")
		end)
	end)
end)
