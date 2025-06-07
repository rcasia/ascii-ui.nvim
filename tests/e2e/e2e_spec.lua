pcall(require, "luacov")
---@module "luassert"

local ui = require("ascii-ui")
local Column = ui.layout.Column
local Options = ui.components.Select
local it = require("plenary.async.tests").it
local Paragraph = ui.components.Paragraph
local Slider = ui.components.Slider
local useState = require("ascii-ui.fiber").useState
local Element = require("ascii-ui.buffer.element")
local interaction_type = require("ascii-ui.interaction_type")

local function feed(keys)
	vim.api.nvim_feedkeys(keys, "mtx", true)
end

local function cursor_is_in_line(number)
	return vim.wait(1, function()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local line = cursor[1]

		return line == number
	end)
end

---@param bufnr integer
---@param pattern string
---@return boolean
local function buffer_contains(bufnr, pattern)
	return vim.wait(1000, function()
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local content_str = vim.iter(lines):join("\n")

		print(content_str)
		print("")
		return string.find(content_str, pattern, 1, true) ~= nil
	end)
end

describe("ascii-ui", function()
	it("should open close and open again with out problems", function()
		local component = Options({ options = {
			"book",
			"pencil",
			"rubber",
		} })

		local bufnr = ui.mount(component)

		assert(buffer_contains(bufnr, "[x] book"))

		vim.api.nvim_buf_delete(bufnr, {})

		-- TODO: check second option can be selected
		-- assert(buffer_contains(bufnr_2, "[x] pencil"))
	end)

	describe("sliders", function()
		-- FIX: does not update on interaction due to unimplemented hooks for new architecture
		pending("silders slide", function()
			local App = ui.createComponent("App", function()
				return function()
					return Slider({ title = "test-slider" })
				end
			end, {})

			local bufnr = ui.mount(App)
			assert(buffer_contains(bufnr, "0%"))

			feed("llllll")
			assert(buffer_contains(bufnr, "60%"), "no encuentra 60%")

			feed("hhh")
			assert(buffer_contains(bufnr, "0%"), "no encuentra 0%")

			feed("j")
			assert(cursor_is_in_line(3), "no está en 3")

			feed("ll")
			assert(buffer_contains(bufnr, "20%"), "no encuentra 20%")

			feed("lll")
			assert(buffer_contains(bufnr, "50%"))
		end)

		it("fiber functional", function()
			local content, setContent
			local App = ui.createComponent("App", function()
				return function()
					content, setContent = useState("hola mundo")
					return Paragraph({ content = content() })
				end
			end, {})
			local bufnr = ui.mount(App)
			assert(buffer_contains(bufnr, "hola mundo"))

			setContent("lemon juice")
			assert(buffer_contains(bufnr, "lemon juice"))
		end)

		it("fiber functional interaction", function()
			local content, setContent
			local App = ui.createComponent("App", function()
				return function()
					content, setContent = useState("hola mundo")
					return {
						Element:new({
							content = content(),
							interactions = {
								[interaction_type.CURSOR_MOVE_RIGHT] = function()
									setContent("right")
								end,
								[interaction_type.CURSOR_MOVE_LEFT] = function()
									setContent("left")
								end,
							},
						}):wrap(),
					}
				end
			end, {})
			local bufnr = ui.mount(App)
			assert(buffer_contains(bufnr, "hola mundo"))

			feed("l")
			assert(buffer_contains(bufnr, "right"))

			feed("h")
			assert(buffer_contains(bufnr, "left"))
		end)
	end)
end)
