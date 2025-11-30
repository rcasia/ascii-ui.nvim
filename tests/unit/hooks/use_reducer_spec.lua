pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local Segment = require("ascii-ui.buffer.segment")
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
				return { Segment:new({ content = tostring(value) }):wrap() }
			end
		end)

		local root = fiber.render(C)
		local buf = root:get_buffer()
		eq({ "5" }, buf:to_lines())

		-- dispatch via closure
		dispatch("inc")
		local root_result = fiber.rerender(root)
		local new_buf = root_result:get_buffer()
		eq({ "6" }, new_buf:to_lines())

		dispatch("dec")
		local root_result2 = fiber.rerender(root)
		local new_buf2 = root_result2:get_buffer()
		eq({ "5" }, new_buf2:to_lines())
	end)
end)
