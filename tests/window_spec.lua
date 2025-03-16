local Window = require("one-ui.window")

describe("window", function()
	it("should open", function()
		local window = Window:new()
		window:open()

		assert.is_true(window:is_open())

		window:close()
		assert.is_false(window:is_open())
	end)
end)
