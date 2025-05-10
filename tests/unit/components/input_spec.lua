pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Input = require("ascii-ui.components.input")

--- @param bufferlines ascii-ui.BufferLine[]
--- @return string
local function bufferlines_to_string(bufferlines)
	return vim
		.iter(bufferlines)
		--- @param line ascii-ui.BufferLine
		:map(function(line)
			return line:to_string()
		end)
		:join("\n")
end

describe("Input", function()
	it("renders", function()
		local input_closure = Input()
		local result = bufferlines_to_string(input_closure())

		eq("", result)
	end)

	it("renders with initial value", function()
		local initial_value = "hello world!"
		local input_closure = Input({ value = initial_value })
		local result = bufferlines_to_string(input_closure())

		eq(initial_value, result)
	end)
end)
