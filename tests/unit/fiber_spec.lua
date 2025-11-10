pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same

local FiberNode = require("ascii-ui.fibernode")
local Segment = require("ascii-ui.buffer.segment")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")
local useState = ui.hooks.useState
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
