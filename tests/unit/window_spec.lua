pcall(require, "luacov")
local Buffer = require("ascii-ui.buffer")
local Window = require("ascii-ui.window")

local assert = require("luassert")

describe("window", function()
	it("should open and close", function()
		local window = Window.new()
		window:open()

		assert.is_true(window:is_open())

		window:close()
		assert.is_false(window:is_open())
	end)

	it("should show render", function()
		local window = Window.new()
		window:open()

		window:update(Buffer.from_lines({ "Hello, World!" }))

		window:close()
	end)
end)
