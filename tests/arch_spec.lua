pcall(require, "luacov")
local assert = require("luassert")

describe("arch tests", function()
	it("all test files start with line pcall(require, 'luacov')", function()
		local expected_line = [[pcall(require, "luacov")]]
		local handle = assert(io.popen("find ./tests -type f -name '*_spec.lua'"))

		for file in handle:lines() do
			local f = assert(io.open(file, "r"))
			assert(f, "Failed to open file: " .. file)
			local first_line = f:read("*l")
			f:close()

			assert.are.equal(expected_line, first_line, "File " .. file .. " does not start with the expected line")
		end
		handle:close()
	end)
end)
