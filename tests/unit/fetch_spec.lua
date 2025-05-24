pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

--- @param url string
local function fetch(url)
	local result = vim.system({ "curl", "-s", url }):wait()
	if result.code ~= 0 then
		return nil
	end
	return vim.json.decode(result.stdout)
end

describe("fetch", function()
	before_each(function()
		local result = vim.system({ "docker", "compose", "up", "-d", "--wait" }):wait()
		assert(result.code == 0, "could not spin up docker: " .. vim.inspect(result))

		vim.system({ "sleep", "3" }):wait()
	end)

	after_each(function()
		vim.system({ "docker", "compose", "down" }):wait()
	end)

	it("executes GET request", function()
		local response_body
		vim.wait(200, function()
			response_body = fetch("http://localhost:8080/ping")
			return response_body ~= nil
		end)

		assert.not_nil(response_body)

		local path_params = vim.tbl_values(response_body.request.params)
		eq({ "/ping" }, path_params)
	end)
end)
