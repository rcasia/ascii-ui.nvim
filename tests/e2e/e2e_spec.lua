pcall(require, "luacov")
---@module "luassert"

local ui = require("ascii-ui")
local Select = ui.components.Select
local it = require("plenary.async.tests").it
local Paragraph = ui.components.Paragraph
local Slider = ui.components.Slider
local useState = require("ascii-ui.fiber").useState
local Segment = require("ascii-ui.buffer.segment")
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
	it("interacts with segments of a Select component", function()
		local App = ui.createComponent("App", function()
			return Select({ options = {
				"book",
				"pencil",
				"rubber",
			} })
		end)

		local bufnr = ui.mount(App)

		assert(buffer_contains(bufnr, "[x] book"))

		-- move down and press enter
		feed("j")
		local enter = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
		feed(enter) -- simulate pressing Enter on the button

		assert(buffer_contains(bufnr, "[x] pencil"))
	end)

	describe("sliders", function()
		it("sliders slide", function()
			local App = ui.createComponent("App", function()
				return {
					--
					Slider({ title = "test-slider 1" }),
					Slider({ title = "test-slider 2" }),
				}
			end)

			local bufnr = ui.mount(App)
			assert(buffer_contains(bufnr, "0%"))

			feed("j")

			feed("llllll")
			assert(buffer_contains(bufnr, "60%"), "no encuentra 60%")

			feed("hhh")
			assert(buffer_contains(bufnr, "30%"), "no encuentra 30%")

			feed("j")
			assert(cursor_is_in_line(4), "no está en la línea 4")

			feed("ll")
			assert(buffer_contains(bufnr, "20%"), "no encuentra 20%")

			feed("lll")
			assert(buffer_contains(bufnr, "50%"))
		end)

		it("fiber functional", function()
			local content, setContent
			local App = ui.createComponent("App", function()
				content, setContent = useState("hola mundo")
				return Paragraph({ content = content })
			end)
			local bufnr = ui.mount(App)
			assert(buffer_contains(bufnr, "hola mundo"))

			setContent("lemon juice")
			assert(buffer_contains(bufnr, "lemon juice"))
		end)

		it("fiber functional interaction", function()
			local content, setContent
			local App = ui.createComponent("App", function()
				content, setContent = useState("hola mundo")
				return {
					Segment:new({
						content = content,
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
			end)
			local bufnr = ui.mount(App)
			assert(buffer_contains(bufnr, "hola mundo"))

			feed("l")
			assert(buffer_contains(bufnr, "right"))

			feed("h")
			assert(buffer_contains(bufnr, "left"))
		end)
	end)

	it("fiber functional interaction with inner component", function()
		local content, setContent
		local SomeComponent = ui.createComponent("SomeComponent", function()
			content, setContent = useState("hola mundo")
			return {
				Segment:new({
					content = content,
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
		end)
		local App = ui.createComponent("App", function()
			return SomeComponent()
		end)
		local bufnr = ui.mount(App)
		assert(buffer_contains(bufnr, "hola mundo"))

		feed("l")
		assert(buffer_contains(bufnr, "right"))

		feed("h")
		assert(buffer_contains(bufnr, "left"))
	end)
end)
