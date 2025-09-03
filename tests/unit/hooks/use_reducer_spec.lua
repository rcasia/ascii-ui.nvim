pcall(require, "luacov")
local assert = require("luassert")

local eq = assert.are.same
local Element = require("ascii-ui.buffer.element")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")
local useReducer = require("ascii-ui.hooks.use_reducer")

describe("useReducer", function()
	it("inicializa y despacha acciones correctamente", function()
		local function reducer(s, a)
			return s + (a == "inc" and 1 or -1)
		end

		local value, dispatch
		local C = ui.createComponent("C", function()
			return function()
				value, dispatch = useReducer(reducer, 5)
				return { Element:new({ content = tostring(value) }):wrap() }
			end
		end)

		local buf, root = fiber.render(C)
		eq({ "5" }, buf:to_lines())

		-- dispatch via closure
		dispatch("inc")
		local new_buf = fiber.rerender(root)
		eq({ "6" }, new_buf:to_lines())

		dispatch("dec")
		local new_buf2 = fiber.rerender(root)
		eq({ "5" }, new_buf2:to_lines())
	end)
end)
