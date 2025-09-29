pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local FiberNode = require("ascii-ui.fibernode")
local Segment = require("ascii-ui.buffer.segment")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")
local useState = fiber.useState
local useEffect = fiber._useEffect
local logger = require("ascii-ui.logger")

local MyComponent = ui.createComponent("MyComponent", function(props)
	props = props or {}
	return function()
		return { Segment:new({ content = props.content or "Hello World" }):wrap() }
	end
end, { content = "string" })

local App = ui.createComponent("App", function()
	return function()
		return MyComponent()
	end
end, {})

describe("Fiber", function()
	it("renderiza MyComponent en una sola línea", function()
		local buffer, rootFiber = fiber.render(App)
		eq({ "Hello World" }, buffer:to_lines())

		fiber.debugPrint(rootFiber)
	end)

	it("renderiza List en dos líneas", function()
		local List = ui.createComponent("List", function()
			return function()
				return {
					Segment:new({ content = "Línea 1" }):wrap(),
					Segment:new({ content = "Línea 2" }):wrap(),
				}
			end
		end, {})
		local lines, rootFiber = fiber.render(List)
		eq({ "Línea 1", "Línea 2" }, lines:to_lines())

		fiber.debugPrint(rootFiber)
	end)

	it("un componente compuesto", function()
		local SomeComponent = ui.createComponent("SomeComponent", function()
			return { Segment:new({ content = "Componente Interno" }):wrap() }
		end, {})
		local List = ui.createComponent("List", function()
			return {
				SomeComponent(),
			}
		end, {})

		local lines, rootFiber = fiber.render(List)
		fiber.debugPrint(rootFiber, print)
		eq({ "Componente Interno" }, lines:to_lines())
		eq("List", rootFiber.type)
		eq("SomeComponent", rootFiber.child.type)
		eq(nil, rootFiber.child.sibling, "No debe haber hermanos en este caso")
	end)

	it("soporta useState y re-renderiza al actualizar", function()
		-- componente con contador
		local count, setCount
		local active, setActive
		local Counter = ui.createComponent("Counter", function()
			count, setCount = useState(0)
			active, setActive = useState(false)
			return {
				Segment:new({ content = "c:" .. count }):wrap(),
				Segment:new({ content = "b:" .. tostring(active) }):wrap(),
			}
		end, {})

		-- render inicial
		local buf1, root = fiber.render(Counter)
		eq({ "c:0", "b:false" }, buf1:to_lines())

		-- disparar actualización
		setCount(5)
		setActive(true)

		local buf2 = fiber.rerender(root)
		-- tras el setState, el propio hook habrá vuelto a renderizar
		local lines2 = buf2:to_lines()
		eq({ "c:5", "b:true" }, lines2)

		fiber.debugPrint(root)
	end)

	it("debe ejecutar el efecto una vez tras el primer render", function()
		local invocations = 0

		local Test = ui.createComponent("Test", function()
			-- efecto sin deps ({}): se ejecuta siempre una vez
			useEffect(function()
				invocations = invocations + 1
			end, {})

			return { Segment:new({ content = "foo" }):wrap() }
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
					runs[#runs + 1] = count
				end, { count })
				return { Segment:new({ content = tostring(count) }):wrap() }
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
		fiber.rerender(root)
		eq({ 0, 1 }, runs, "Se reejecuta al cambiar count a 1")

		-- otra vez a 1: no debe reejecutar
		setCount(1)
		fiber.rerender(root)
		eq({ 0, 1 }, runs, "Mismo valor de dep no dispara efecto")

		-- cambiamos a 2: sí
		setCount(2)
		fiber.rerender(root)
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
					logs[#logs + 1] = "run:" .. count
					return function()
						-- cleanup: registramos también
						logs[#logs + 1] = "cleanup:" .. count
					end
				end, { count })

				return { Segment:new({ content = tostring(count) }):wrap() }
			end
		end, {})

		-- primer render: effect se ejecuta, no hay cleanup aún
		local _, root = fiber.render(Counter)
		eq({ "run:0" }, logs)

		-- primer cambio de estado a 1: debe correrse cleanup(0) antes de run(1)
		setCount(1)
		fiber.rerender(root)
		eq({ "run:0", "cleanup:0", "run:1" }, logs)

		-- otro cambio a 2: cleanup(1) y run(2)
		setCount(2)
		fiber.rerender(root)
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

				return { Segment:new({ content = "foo" }):wrap() }
			end
		end, {})

		-- Mount
		local _, root = fiber.render(Test)
		eq({ "mounted" }, log, "solo debería haber corrido el efecto")

		-- Unmount (lo que vamos a implementar)
		root:unmount()
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

				return { Segment:new({ content = "foo" }):wrap() }
			end
		end, {})

		-- mount inicial
		local _, root = fiber.render(Test)
		eq({ "effect1", "effect2" }, log, "Los efectos deben correrse en orden declarado")

		-- rerender genérico (sin deps, así siempre both effects vuelven a correr)
		log = {}
		fiber.rerender(root)
		fiber.debugPrint(root)
		eq({
			"cleanup1",
			"effect1",
			"cleanup2",
			"effect2",
		}, log, "Los cleanups se ejecutan en orden inverso, luego los efectos en orden")
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
				return { Segment:new({ content = tostring(val) }):wrap() }
			end
		end, {})

		fiber.render(C)
		setVal(1) -- actualiza estado
		assert.are.same({ "effect" }, log)
	end)

	describe("reconcileChildren", function()
		it("sets parent, root, child and sibling correctly", function()
			-- Hojas simples: cada una envuelve una única línea
			local ChildA = ui.createComponent("ChildA", function()
				return function()
					return { Segment:new({ content = "A" }):wrap() }
				end
			end, {})

			local countB, setCountB
			local ChildB = ui.createComponent("ChildB", function()
				return function()
					countB, setCountB = useState(0)
					return { Segment:new({ content = "B:" .. countB }):wrap() }
				end
			end, {})

			local countC, setCountC
			local ChildC = ui.createComponent("ChildC", function()
				return function()
					countC, setCountC = useState(0)
					return { Segment:new({ content = "C:" .. countC }):wrap() }
				end
			end, {})

			local countApp, setCountApp
			-- Componente raíz que agrupa los tres hijos, mismo estilo que tu List
			local Test = ui.createComponent("App", function()
				return function()
					countApp, setCountApp = useState(0)

					-- Llamamos a cada hijo y extraemos su FiberNode (primer segmento de la tabla)
					return ui.layout.Column(
						ChildA(),
						ChildB(),
						ChildC(),
						MyComponent({ content = "App:" .. tostring(countApp) })
					)
				end
			end)

			local buf, root = fiber.render(Test)

			--- @param node ascii-ui.FiberNode
			local child_c = vim.iter(root:iter()):find(function(node)
				return node.type == "ChildC"
			end)
			logger.debug(
				[[BUFFER:
%s
			]],
				buf:to_string()
			)

			assert(child_c, "should find child_c")
			eq("ChildC", child_c.type)
			eq("C:0", child_c.child:get_line():to_string())

			setCountC(1)
			setCountB(2)
			setCountApp(3)
			fiber.rerender(root)

			--- @param node ascii-ui.FiberNode
			local child_c2 = vim.iter(root:iter()):find(function(node)
				return node.type == "ChildC"
			end)

			fiber.debugPrint(root, function(line)
				logger.debug("rerendered: " .. line)
			end)

			assert(child_c2, "child_c2 should not be nil on rerender")
			eq("ChildC", child_c2.type)
			eq("C:1", child_c2.child:get_line():to_string())

			--- @param node ascii-ui.FiberNode
			local child_b = vim.iter(root:iter()):find(function(node)
				return node.type == "ChildB"
			end)

			eq("ChildB", child_b.type)
			eq("B:2", child_b.child:get_line():to_string())

			--- @type ascii-ui.FiberNode
			local my_component = vim.iter(root:iter()):find(function(node)
				return node.type == "MyComponent"
			end)

			eq("App:3", my_component.child:get_line():to_string())
		end)

		it("handles parent.output being nil", function()
			local parent = FiberNode.new({ name = "Root", type = "Root" })
			local output = {
				FiberNode.new({ type = "One" }),
			}
			parent.output = nil

			fiber.reconcileChildren(parent, output)

			assert.equals("One", parent.child.type)
		end)
	end)
end)
