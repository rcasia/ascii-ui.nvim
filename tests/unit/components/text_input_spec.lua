---@module "luassert"
local eq = assert.are.same

local TextInput = require("ascii-ui.components.text_input")

describe("TextInput", function()
	it("should create", function()
		local content = "hello world!"
		local txt_input = TextInput:new(content)
		eq(content, txt_input.content)
	end)
end)
