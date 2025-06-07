pcall(require, "luacov")
---@module "luassert"

local eq = assert.are.same
local logger = require("ascii-ui.logger")

local Buffer = require("ascii-ui.buffer")
local Element = require("ascii-ui.buffer.element")
local _fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")
local render = _fiber.render
local useState = _fiber.useState
local commitWork = _fiber.commitWork
local workLoop = _fiber.workLoop

--- @class ascii-ui.FiberNode
--- @field type "Root" | string
--- @field closure fun(): function, ascii-ui.FiberNode[]
--- @field output ascii-ui.FiberNode[] | ascii-ui.BufferLine[] | nil
--- @field root ascii-ui.FiberNode | nil
--- @field child ascii-ui.FiberNode | nil
--- @field sibling ascii-ui.FiberNode | nil
--- @field parent ascii-ui.FiberNode | nil
--- @field hookIndex integer
--- @field hooks table[]

local MyComponent = ui.createComponent("MyComponent", function()
	return function()
		return { Element:new({ content = "Hello World" }):wrap() }
	end
end, {})

local App = ui.createComponent("App", function()
	return MyComponent()
end, {})

describe("Fiber", function()
	it("renderiza MyComponent en una sola línea", function()
		local lines = render(App)
		eq({ "Hello World" }, lines:to_lines())
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
		local lines = render(List)
		eq({ "Línea 1", "Línea 2" }, lines:to_lines())
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
		local _, fiber = Counter()
		local rootFiber = fiber[1]
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
	end)
end)
