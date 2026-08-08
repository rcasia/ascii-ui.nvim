pcall(require, "luacov")
---@module "luassert"

local error_handler = require("ascii-ui.utils.error_handler")

describe("error_handler", function()
	describe("format_error", function()
		it("formats a render error with component path", function()
			local err = error_handler.format_error("render", "Root > App > MenuItem", "expected list, got string")
			assert.are.equal("[render] in <Root > App > MenuItem>: expected list, got string", err)
		end)

		it("formats a hook error", function()
			local err = error_handler.format_error("hook", "App > Sidebar", "useState called outside render")
			assert.are.equal("[hook] in <App > Sidebar>: useState called outside render", err)
		end)

		it("formats an effect error", function()
			local err = error_handler.format_error("effect", "Button", "effect exploded")
			assert.are.equal("[effect] in <Button>: effect exploded", err)
		end)

		it("formats an interaction error", function()
			local err = error_handler.format_error("interaction", "Select", "on_select failed")
			assert.are.equal("[interaction] in <Select>: on_select failed", err)
		end)

		it("formats a viewport error", function()
			local err = error_handler.format_error("viewport", "Root", "window creation failed")
			assert.are.equal("[viewport] in <Root>: window creation failed", err)
		end)

		it("handles nil component path gracefully", function()
			local err = error_handler.format_error("render", nil, "something broke")
			assert.are.equal("[render] in <unknown>: something broke", err)
		end)

		it("handles empty component path", function()
			local err = error_handler.format_error("render", "", "something broke")
			assert.are.equal("[render] in <unknown>: something broke", err)
		end)
	end)

	describe("render_error_to_lines", function()
		it("returns a table of strings", function()
			local err = {
				err_type = "render",
				component_path = "Root > App",
				message = "expected list, got string",
			}
			local lines = error_handler.render_error_to_lines(err)
			assert.are.same("table", type(lines))
			assert.is_true(#lines > 0)
		end)

		it("includes error header", function()
			local err = {
				err_type = "render",
				component_path = "Root > App",
				message = "test error",
			}
			local lines = error_handler.render_error_to_lines(err)
			local joined = table.concat(lines, "\n")
			assert.truthy(joined:find("RENDER ERROR"))
		end)

		it("includes error type", function()
			local err = {
				err_type = "hook",
				component_path = "App",
				message = "hook failed",
			}
			local lines = error_handler.render_error_to_lines(err)
			local joined = table.concat(lines, "\n")
			assert.truthy(joined:find("Type: hook"))
		end)

		it("includes component path", function()
			local err = {
				err_type = "render",
				component_path = "Root > App > MenuItem",
				message = "test error",
			}
			local lines = error_handler.render_error_to_lines(err)
			local joined = table.concat(lines, "\n")
			assert.truthy(joined:find("Component: Root > App > MenuItem"))
		end)

		it("includes error message", function()
			local err = {
				err_type = "render",
				component_path = "App",
				message = "something went wrong",
			}
			local lines = error_handler.render_error_to_lines(err)
			local joined = table.concat(lines, "\n")
			assert.truthy(joined:find("Message: something went wrong"))
		end)

		it("includes hint for render errors", function()
			local err = {
				err_type = "render",
				component_path = "App",
				message = "expected list, got string",
			}
			local lines = error_handler.render_error_to_lines(err)
			local joined = table.concat(lines, "\n")
			assert.truthy(joined:find("Hint:"))
		end)

		it("includes hint for hook errors", function()
			local err = {
				err_type = "hook",
				component_path = "App",
				message = "useState called outside render",
			}
			local lines = error_handler.render_error_to_lines(err)
			local joined = table.concat(lines, "\n")
			assert.truthy(joined:find("Hint:"))
		end)

		it("includes closing border", function()
			local err = {
				err_type = "render",
				component_path = "App",
				message = "test",
			}
			local lines = error_handler.render_error_to_lines(err)
			local last_line = lines[#lines]
			assert.truthy(last_line:find("═"))
		end)
	end)

	describe("create_error", function()
		it("creates an error table with all fields", function()
			local err = error_handler.create_error("render", "Root > App", "test message")
			assert.are.equal("render", err.err_type)
			assert.are.equal("Root > App", err.component_path)
			assert.are.equal("test message", err.message)
		end)

		it("handles nil component path", function()
			local err = error_handler.create_error("render", nil, "test")
			assert.are.equal("unknown", err.component_path)
		end)
	end)

	describe("get_hint", function()
		it("returns hint for render errors", function()
			local hint = error_handler.get_hint("render")
			assert.truthy(hint)
			assert.are.same("string", type(hint))
			assert.truthy(#hint > 0)
		end)

		it("returns hint for hook errors", function()
			local hint = error_handler.get_hint("hook")
			assert.truthy(hint)
			assert.truthy(#hint > 0)
		end)

		it("returns hint for effect errors", function()
			local hint = error_handler.get_hint("effect")
			assert.truthy(hint)
			assert.truthy(#hint > 0)
		end)

		it("returns hint for interaction errors", function()
			local hint = error_handler.get_hint("interaction")
			assert.truthy(hint)
			assert.truthy(#hint > 0)
		end)

		it("returns hint for viewport errors", function()
			local hint = error_handler.get_hint("viewport")
			assert.truthy(hint)
			assert.truthy(#hint > 0)
		end)

		it("returns generic hint for unknown error types", function()
			local hint = error_handler.get_hint("unknown_type")
			assert.truthy(hint)
			assert.truthy(#hint > 0)
		end)
	end)
end)
