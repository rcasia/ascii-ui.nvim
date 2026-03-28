pcall(require, "luacov")
---@module "luassert"

local FiberNode = require("ascii-ui.fibernode")

describe("FiberNode:run_pending error reporting", function()
	it("reports the component name when a pending effect throws", function()
		local node = FiberNode.new({
			type = "Slider",
			pendingEffects = {
				function()
					error("effect exploded")
				end,
			},
		})

		local ok, err = pcall(function()
			node:run_pending()
		end)

		assert.is_false(ok)
		assert.truthy(err:find("Slider"), "error should mention the component name 'Slider'")
		assert.truthy(err:find("effect exploded"), "error should contain the original reason")
	end)

	it("reports the component name when a repeating effect throws", function()
		local node = FiberNode.new({ type = "MyComp" })
		node.repeatingEffects = {
			function()
				error("repeating boom")
			end,
		}

		local ok, err = pcall(function()
			node:run_pending()
		end)

		assert.is_false(ok)
		assert.truthy(err:find("MyComp"), "error should mention the component name 'MyComp'")
		assert.truthy(err:find("repeating boom"), "error should contain the original reason")
	end)

	it("reports the component name when a pending cleanup throws", function()
		local node = FiberNode.new({ type = "Button" })
		node.pendingCleanups = {
			function()
				error("cleanup failed")
			end,
		}

		local ok, err = pcall(function()
			node:run_pending()
		end)

		assert.is_false(ok)
		assert.truthy(err:find("Button"), "error should mention the component name 'Button'")
		assert.truthy(err:find("cleanup failed"), "error should contain the original reason")
	end)
end)
