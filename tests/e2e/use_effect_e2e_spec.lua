pcall(require, "luacov")
---@module "luassert"

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local useState = ui.hooks.useState
local useEffect = ui.hooks.useEffect
local Segment = ui.blocks.Segment

local eq = assert.are.same

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

describe("useInterval", function()
	local useEffect_invocations = 0

	it("executes useEffect after first render", function()
		local App = ui.createComponent("App", function()
			local message, setMessage = useState("Not updated :(")

			useEffect(function()
				setMessage("Updated! :)")
			end, {})

			return {
				Paragraph({ content = message }),
			}
		end)

		local bufnr = ui.mount(App)
		vim.wait(1000, function()
			return false
		end)

		assert(buffer_contains(bufnr, ":)"))
	end)

	it("executes useEffect after first render", function()
		local App = ui.createComponent("App", function()
			local message, setMessage = useState("Not updated :(")

			useEffect(function()
				setMessage("Updated! :)")
			end, {})

			return {
				Paragraph({ content = message }),
			}
		end)

		local bufnr = ui.mount(App)
		vim.wait(1000, function()
			return false
		end)

		assert(buffer_contains(bufnr, ":)"))
	end)

	it("executes when the dependencies change", function()
		local runs = {}
		local count, setCount
		local Counter = ui.createComponent("Counter", function()
			count, setCount = useState(0)

			-- efecto con arreglo de deps = { count() }
			useEffect(function()
				-- registramos cada ejecución junto con el valor actual de count
				runs[#runs + 1] = count
			end, { count })
			return { Segment({ content = tostring(count) }):wrap() }
		end, {})

		ui.mount(Counter) -- mount to trigger effects
		eq({ 0 }, runs, "Debe ejecutarse con count=0 en el mount")

		setCount(1)
		eq({ 0, 1 }, runs, "Se reejecuta al cambiar count a 1")

		-- otra vez a 1: no debe reejecutar
		setCount(1)
		eq({ 0, 1 }, runs, "Mismo valor de dep no dispara efecto")

		-- cambiamos a 2: sí
		setCount(2)
		eq({ 0, 1, 2 }, runs, "Se reejecuta al cambiar count a 2")
	end)

	it("calls cleanup before recalling useEffect", function()
		local logs = {}

		local count, setCount
		local Counter = ui.createComponent("Counter", function()
			count, setCount = useState(0)

			useEffect(function()
				-- efecto: registramos la ejecución
				logs[#logs + 1] = "run:" .. count
				return function()
					-- cleanup: registramos también
					logs[#logs + 1] = "cleanup:" .. count
				end
			end, { count })

			return { Segment({ content = tostring(count) }):wrap() }
		end, {})

		ui.mount(Counter) -- mount to trigger effects
		eq({ "run:0" }, logs)

		setCount(1)
		eq({ "run:0", "cleanup:0", "run:1" }, logs)

		setCount(2)
		eq({ "run:0", "cleanup:0", "run:1", "cleanup:1", "run:2" }, logs)
	end)

	-- FIXME: there's not api to unmount an ui yet
	pending("execute cleanup on component unmount", function()
		local log = {}

		local Test = ui.createComponent("Test", function()
			useEffect(function()
				log[#log + 1] = "mounted"
				return function()
					log[#log + 1] = "unmounted"
				end
			end)

			return { Segment({ content = "foo" }):wrap() }
		end, {})

		ui.mount(Test)
		eq({ "mounted" }, log, "solo debería haber corrido el efecto")

		eq({ "mounted", "unmounted" }, log, "el cleanup debe ejecutarse al unmount")
	end)

	it("ejecuta efectos en orden y cleanups en orden inverso", function()
		local log = {}

		local tick, setTick
		local Test = ui.createComponent("Test", function()
			tick, setTick = useState(0)

			-- primer efecto
			useEffect(function()
				log[#log + 1] = "effect1"
				return function()
					log[#log + 1] = "cleanup1"
				end
			end, { tick })

			-- segundo efecto
			useEffect(function()
				log[#log + 1] = "effect2"
				return function()
					log[#log + 1] = "cleanup2"
				end
			end, { tick })

			return { Segment({ content = "foo" }):wrap() }
		end, {})

		ui.mount(Test)
		eq({ "effect1", "effect2" }, log, "Los efectos deben correrse en orden declarado")

		-- rerender genérico (sin deps, así siempre both effects vuelven a correr)
		log = {}
		setTick(1)
		eq({
			"cleanup1",
			"cleanup2",
			"effect1",
			"effect2",
		}, log, "Los cleanups se ejecutan en orden inverso, luego los efectos en orden")
	end)

	it("no ejecuta cleanup de effect [] al hacer setState", function()
		local log = {}
		local val, setVal

		local C = ui.createComponent("C", function()
			val, setVal = useState(0)
			useEffect(function()
				log[#log + 1] = "effect"
				return function()
					log[#log + 1] = "cleanup"
				end
			end, {}) -- deps vacías
			return { Segment({ content = tostring(val) }):wrap() }
		end, {})

		ui.mount(C)
		setVal(1) -- actualiza estado
		eq({ "effect" }, log)
	end)
end)
