pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local Buffer = require("ascii-ui.buffer")
local Element = require("ascii-ui.buffer.element")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")
local render = fiber.render
local useState = fiber.useState
local useEffect = fiber.useEffect
local commitWork = fiber.commitWork
local workLoop = fiber.workLoop
local debugPrint = fiber.debugPrint

local MyComponent = ui.createComponent("MyComponent", function()
	return function()
		return { Element:new({ content = "Hello World" }):wrap() }
	end
end, {})

local App = ui.createComponent("App", function()
	return function()
		return MyComponent()
	end
end, {})

describe("Fiber", function()
	it("renderiza MyComponent en una sola línea", function()
		local buffer, rootFiber = render(App)
		eq({ "Hello World" }, buffer:to_lines())

		debugPrint(rootFiber)
	end)

	it("renderiza List en dos líneas", function()
		local List = ui.createComponent("List", function()
			return function()
				return {
					Element:new({ content = "Línea 1" }):wrap(),
					Element:new({ content = "Línea 2" }):wrap(),
				}
			end
		end, {})
		local lines, rootFiber = render(List)
		eq({ "Línea 1", "Línea 2" }, lines:to_lines())

		debugPrint(rootFiber)
	end)

	it("un componente compuesto", function()
		local SomeComponent = ui.createComponent("SomeComponent", function()
			return function()
				return { Element:new({ content = "Componente Interno" }):wrap() }
			end
		end, {})
		local List = ui.createComponent("List", function()
			return function()
				return SomeComponent()
			end
		end, {})

		local lines, rootFiber = render(List)
		eq({ "Componente Interno" }, lines:to_lines())
		eq("SomeComponent", rootFiber.child.type)
		eq(nil, rootFiber.child.sibling, "No debe haber hermanos en este caso")
		-- eq(nil, rootFiber.child.child, "No debe haber hijos en este caso")
		-- eq({}, rootFiber.output[1].output)

		debugPrint(rootFiber)
	end)

	it("soporta useState y re-renderiza al actualizar", function()
		-- componente con contador
		local count, setCount
		local active, setActive
		local Counter = ui.createComponent("Counter", function()
			return function()
				count, setCount = useState(0)
				active, setActive = useState(false)
				return {
					Element:new({ content = "c:" .. count() }):wrap(),
					Element:new({ content = "b:" .. tostring(active()) }):wrap(),
				}
			end
		end, {})

		-- render inicial
		local _rootFiber = Counter()
		local rootFiber = _rootFiber[1]
		workLoop(rootFiber)
		local buf1 = Buffer.new()
		commitWork(rootFiber, buf1)
		eq({ "c:0", "b:false" }, buf1:to_lines())

		-- disparar actualización
		setCount(5)
		setActive(true)

		-- tras el setState, el propio hook habrá vuelto a renderizar
		local lines2 = rootFiber.lastRendered:to_lines()
		eq({ "c:5", "b:true" }, lines2)

		debugPrint(rootFiber)
	end)

	it("debe ejecutar el efecto una vez tras el primer render", function()
		local invocations = 0

		local Test = ui.createComponent("Test", function()
			-- efecto sin deps ({}): se ejecuta siempre una vez
			return function()
				useEffect(function()
					invocations = invocations + 1
				end, {})

				return { Element:new({ content = "foo" }):wrap() }
			end
		end)

		-- primer render
		local _, fiberRoot = fiber.render(Test)
		eq(1, invocations, "useEffect debió ejecutarse una vez después del render inicial")

		-- un rerender sin cambios de estado no debe volver a ejecutarlo
		local _ = fiber.rerender(fiberRoot)
		eq(1, invocations, "useEffect sin deps no debe reejecutarse en rerender")
	end)

	it("solo se vuelve a ejecutar cuando cambian las dependencias", function()
		local runs = {}
		local count, setCount
		local Counter = ui.createComponent("Counter", function()
			return function()
				count, setCount = useState(0)

				-- efecto con arreglo de deps = { count() }
				useEffect(function()
					-- registramos cada ejecución junto con el valor actual de count
					runs[#runs + 1] = count()
				end, { count() })
				return { Element:new({ content = tostring(count()) }):wrap() }
			end
		end, {})

		-- render inicial
		local _, root = fiber.render(Counter)
		eq({ 0 }, runs, "Debe ejecutarse con count=0 en el mount")

		-- rerender sin cambio de estado
		fiber.rerender(root)
		eq({ 0 }, runs, "Sin cambio de deps no debe reejecutarse")

		-- actualizamos estado a 1
		setCount(1)
		eq({ 0, 1 }, runs, "Se reejecuta al cambiar count a 1")

		-- otra vez a 1: no debe reejecutar
		setCount(1)
		eq({ 0, 1 }, runs, "Mismo valor de dep no dispara efecto")

		-- cambiamos a 2: sí
		setCount(2)
		eq({ 0, 1, 2 }, runs, "Se reejecuta al cambiar count a 2")
	end)
	it("debe llamar al cleanup antes de reejecutar el effect", function()
		local logs = {}

		local count, setCount
		local Counter = ui.createComponent("Counter", function()
			return function()
				count, setCount = useState(0)

				useEffect(function()
					-- efecto: registramos la ejecución
					logs[#logs + 1] = "run:" .. count()
					return function()
						-- cleanup: registramos también
						logs[#logs + 1] = "cleanup:" .. count()
					end
				end, { count() })

				return { Element:new({ content = tostring(count()) }):wrap() }
			end
		end, {})

		-- primer render: effect se ejecuta, no hay cleanup aún
		local _, _ = fiber.render(Counter)
		eq({ "run:0" }, logs)

		-- primer cambio de estado a 1: debe correrse cleanup(0) antes de run(1)
		setCount(1)
		eq({ "run:0", "cleanup:0", "run:1" }, logs)

		-- otro cambio a 2: cleanup(1) y run(2)
		setCount(2)
		eq({ "run:0", "cleanup:0", "run:1", "cleanup:1", "run:2" }, logs)
	end)
	it("debe ejecutar el cleanup al desmontar el componente", function()
		local log = {}

		local Test = ui.createComponent("Test", function()
			return function()
				useEffect(function()
					log[#log + 1] = "mounted"
					return function()
						log[#log + 1] = "unmounted"
					end
				end)

				return { Element:new({ content = "foo" }):wrap() }
			end
		end, {})

		-- Mount
		local _, root = fiber.render(Test)
		eq({ "mounted" }, log, "solo debería haber corrido el efecto")

		-- Unmount (lo que vamos a implementar)
		fiber.unmount(root)
		eq({ "mounted", "unmounted" }, log, "el cleanup debe ejecutarse al unmount")
	end)

	it("ejecuta efectos en orden y cleanups en orden inverso", function()
		local log = {}

		local Test = ui.createComponent("Test", function()
			return function()
				-- primer efecto
				useEffect(function()
					log[#log + 1] = "effect1"
					return function()
						log[#log + 1] = "cleanup1"
					end
				end)

				-- segundo efecto
				useEffect(function()
					log[#log + 1] = "effect2"
					return function()
						log[#log + 1] = "cleanup2"
					end
				end)

				return { Element:new({ content = "foo" }):wrap() }
			end
		end, {})

		-- mount inicial
		local _, root = fiber.render(Test)
		eq({ "effect1", "effect2" }, log, "Los efectos deben correrse en orden declarado")

		-- rerender genérico (sin deps, así siempre both effects vuelven a correr)
		log = {}
		fiber.rerender(root)
		eq(
			{ "cleanup2", "cleanup1", "effect1", "effect2" },
			log,
			"Los cleanups se ejecutan en orden inverso, luego los efectos en orden"
		)
	end)

	it("no ejecuta cleanup de effect [] al hacer setState", function()
		local log = {}
		local val, setVal

		local C = ui.createComponent("C", function()
			return function()
				val, setVal = useState(0)
				useEffect(function()
					log[#log + 1] = "effect"
					return function()
						log[#log + 1] = "cleanup"
					end
				end, {}) -- deps vacías
				return { Element:new({ content = tostring(val()) }):wrap() }
			end
		end, {})

		fiber.render(C)
		setVal(1) -- actualiza estado
		assert.are.same({ "effect" }, log)
	end)
end)
