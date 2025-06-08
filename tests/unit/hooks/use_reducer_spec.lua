pcall(require, "luacov")
---@module "luassert"

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

		local get, dispatch
		local C = ui.createComponent("C", function()
			return function()
				get, dispatch = useReducer(reducer, 5)
				return { Element:new({ content = tostring(get()) }):wrap() }
			end
		end)

		local buf, root = fiber.render(C)
		eq({ "5" }, buf:to_lines())

		-- dispatch via closure
		dispatch("inc")
		eq({ "6" }, root.lastRendered:to_lines())

		dispatch("dec")
		eq({ "5" }, root.lastRendered:to_lines())
	end)
end)
