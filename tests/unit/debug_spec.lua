pcall(require, "luacov")
---@module "luassert"

local ui = require("ascii-ui")

describe("ui.debug", function()
	it("calls mounter with the component returned by loader", function()
		local component = ui.createComponent("Fixture", function()
			return {}
		end)

		local captured = nil
		ui.debug("any/path.lua", {
			loader = function(_)
				return component
			end,
			mounter = function(comp)
				captured = comp
			end,
		})

		assert.are.same(component, captured)
	end)

	it("returns the value from mounter", function()
		local bufnr = ui.debug("any/path.lua", {
			loader = function(_)
				return ui.createComponent("Fixture", function()
					return {}
				end)
			end,
			mounter = function(_)
				return 99
			end,
		})

		assert.are.same(99, bufnr)
	end)

	describe("when loader throws", function()
		local function broken_loader(_)
			error("syntax error in component file")
		end

		it("calls notifier with ERROR level", function()
			local notified = nil
			ui.debug("bad/path.lua", {
				loader = broken_loader,
				mounter = function(_) end,
				notifier = function(msg, level)
					notified = { msg = msg, level = level }
				end,
			})

			assert.is_not_nil(notified)
			assert.are.same(vim.log.levels.ERROR, notified.level)
		end)

		it("does not call mounter", function()
			local mounter_called = false
			ui.debug("bad/path.lua", {
				loader = broken_loader,
				mounter = function(_)
					mounter_called = true
				end,
				notifier = function(_) end,
			})

			assert.is_false(mounter_called)
		end)

		it("returns nil", function()
			local result = ui.debug("bad/path.lua", {
				loader = broken_loader,
				mounter = function(_) end,
				notifier = function(_) end,
			})

			assert.is_nil(result)
		end)
	end)

	describe("integration", function()
		it("loads a real component file with dofile and mounts it", function()
			local fixture = vim.fn.fnamemodify("tests/util/debug_fixture_comp.lua", ":p")
			local bufnr = ui.debug(fixture)

			assert.is_number(bufnr)
			assert.is_true(bufnr > 0)

			-- wait for the component to render into the buffer
			local found = vim.wait(1000, function()
				local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
				local content = table.concat(lines, "\n")
				return content:find("debug fixture loaded", 1, true) ~= nil
			end)
			assert.is_true(found)
		end)
	end)
end)
