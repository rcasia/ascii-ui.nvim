pcall(require, "luacov")
---@module "luassert"

local createComponent = require("ascii-ui.components.functional-component")
local Element = require("ascii-ui.buffer.element")
local useState = require("ascii-ui.hooks.use_state")

local eq = assert.are.same

describe("ComponentCreator.createComponent", function()
	it("makes the component to return the same reference of the component closure", function()
		local component = createComponent("DummyComponent", function(props)
			local counter, setCounter = useState(0)

			return function()
				setCounter(counter() + 1)
				return { Element:new((props.content or "dummy_render ") .. tostring(counter())):wrap() }
			end
		end)

		eq(component(), component())
		eq(component({ content = "hola" }), component({ content = "hola" }))
		assert.not_equal(component({ content = "hola" }), component())
	end)
end)
