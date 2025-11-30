pcall(require, "luacov")
---@module "luassert"

local Segment = require("ascii-ui.buffer.segment")
local eq = assert.are.same

describe("Segment", function()
	it("should count ascii characters", function()
		local s = "ascii"
		local segment = Segment:new({ content = s })
		eq(5, segment:len())
	end)

	it("should count unicode characters", function()
		local s = "a😊日€𐍈"
		local segment = Segment:new({ content = s })
		eq(5, segment:len())
	end)
end)
