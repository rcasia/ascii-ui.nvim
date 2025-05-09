pcall(require, "luacov")
---@module "luassert"

local ComponentCreator = require("ascii-ui.components.functional-component")
local Element = require("ascii-ui.buffer.element")
local useState = require("ascii-ui.hooks.use_state")
local create_dummy_component = require("tests.util.dummy_component")

local eq = assert.are.same

describe("ComponentCreator.createComponent", function()
	before_each(function()
		-- Reinicia los componentes registrados antes de cada prueba
		ComponentCreator.components = {}
	end)

	it("makes the component to return the same reference of the component closure", function()
		local component = ComponentCreator.createComponent("DummyComponent", function(props)
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
