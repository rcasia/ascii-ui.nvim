require("luassert")

local Buffer = require("one-ui.buffer")
local eq = assert.are.same

describe("buffer", function()
	it("should be able to create a buffer", function()
		local b = Buffer:new()
		eq("table", type(b))
	end)

	it("creates buffer from array of strings", function()
		local b = Buffer.from_lines({ "1test", "2test" })
		eq({ "1test", "2test" }, b:to_lines())
	end)
end)
