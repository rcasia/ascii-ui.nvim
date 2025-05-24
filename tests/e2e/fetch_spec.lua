pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local it = it

--- @param url string
local function fetch(url)
	local result = vim.system({ "curl", "-s", url }):wait()
	if result.code ~= 0 then
		return nil
	end
	return vim.json.decode(result.stdout)
end

describe("fetch", function()
	it("executes GET request", function()
		local url = "https://httpbin.org/get"
		local response_body = fetch(url)

		assert(response_body, "Response body should not be nil")

		eq(url, response_body.url)
	end)
end)
