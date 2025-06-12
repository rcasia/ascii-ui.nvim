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
       it("renders MyComponent on a single line", function()
		local buffer, rootFiber = render(App)
		eq({ "Hello World" }, buffer:to_lines())

		debugPrint(rootFiber)
	end)

       it("renders List in two lines", function()
		local List = ui.createComponent("List", function()
			return function()
				return {
                                       Element:new({ content = "Line 1" }):wrap(),
                                       Element:new({ content = "Line 2" }):wrap(),
				}
			end
		end, {})
		local lines, rootFiber = render(List)
               eq({ "Line 1", "Line 2" }, lines:to_lines())

		debugPrint(rootFiber)
	end)

       it("a composite component", function()
		local SomeComponent = ui.createComponent("SomeComponent", function()
			return function()
                               return { Element:new({ content = "Inner Component" }):wrap() }
			end
		end, {})
		local List = ui.createComponent("List", function()
			return function()
				return SomeComponent()
			end
		end, {})

		local lines, rootFiber = render(List)
               eq({ "Inner Component" }, lines:to_lines())
		eq("SomeComponent", rootFiber.child.type)
               eq(nil, rootFiber.child.sibling, "There should be no siblings in this case")
               -- eq(nil, rootFiber.child.child, "There should be no children in this case")
		-- eq({}, rootFiber.output[1].output)

		debugPrint(rootFiber)
	end)

       it("supports useState and re-renders on update", function()
               -- component with counter
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

               -- initial render
		local _rootFiber = Counter()
		local rootFiber = _rootFiber[1]
		workLoop(rootFiber)
		local buf1 = Buffer.new()
		commitWork(rootFiber, buf1)
		eq({ "c:0", "b:false" }, buf1:to_lines())

               -- trigger update
		setCount(5)
		setActive(true)

               -- after setState, the hook itself will have re-rendered
		local lines2 = rootFiber.lastRendered:to_lines()
		eq({ "c:5", "b:true" }, lines2)

		debugPrint(rootFiber)
	end)

       it("should run the effect once after the first render", function()
		local invocations = 0

		local Test = ui.createComponent("Test", function()
                       -- effect without deps ({}): always runs once
			return function()
				useEffect(function()
					invocations = invocations + 1
				end, {})

				return { Element:new({ content = "foo" }):wrap() }
			end
		end)

                -- first render
		local _, fiberRoot = fiber.render(Test)
                eq(1, invocations, "useEffect should have run once after the initial render")

                -- a rerender with no state changes should not run it again
		local _ = fiber.rerender(fiberRoot)
                eq(1, invocations, "useEffect without deps should not rerun on rerender")
	end)

       it("only runs again when the dependencies change", function()
		local runs = {}
		local count, setCount
		local Counter = ui.createComponent("Counter", function()
			return function()
				count, setCount = useState(0)

                               -- effect with deps array = { count() }
				useEffect(function()
                                       -- record each run along with the current count value
					runs[#runs + 1] = count()
				end, { count() })
				return { Element:new({ content = tostring(count()) }):wrap() }
			end
		end, {})

                -- initial render
                local _, root = fiber.render(Counter)
                eq({ 0 }, runs, "Should run with count=0 on mount")

                -- rerender without state change
		fiber.rerender(root)
                eq({ 0 }, runs, "Without deps change it should not rerun")

                -- update state to 1
		setCount(1)
                eq({ 0, 1 }, runs, "Reruns when count changes to 1")

                -- again to 1: should not rerun
		setCount(1)
                eq({ 0, 1 }, runs, "Same dep value does not trigger effect")

                -- change to 2: yes
		setCount(2)
                eq({ 0, 1, 2 }, runs, "Reruns when count changes to 2")
	end)
       it("should call cleanup before rerunning the effect", function()
		local logs = {}

		local count, setCount
		local Counter = ui.createComponent("Counter", function()
			return function()
				count, setCount = useState(0)

				useEffect(function()
                               -- effect: log the execution
					logs[#logs + 1] = "run:" .. count()
					return function()
                                                -- cleanup: also log
						logs[#logs + 1] = "cleanup:" .. count()
					end
				end, { count() })

				return { Element:new({ content = tostring(count()) }):wrap() }
			end
		end, {})

                -- first render: effect runs, no cleanup yet
		local _, _ = fiber.render(Counter)
		eq({ "run:0" }, logs)

                -- first state change to 1: cleanup(0) should run before run(1)
		setCount(1)
		eq({ "run:0", "cleanup:0", "run:1" }, logs)

                -- another change to 2: cleanup(1) and run(2)
		setCount(2)
		eq({ "run:0", "cleanup:0", "run:1", "cleanup:1", "run:2" }, logs)
	end)
       it("should run the cleanup when unmounting the component", function()
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
                eq({ "mounted" }, log, "only the effect should have run")

                -- Unmount (what we are going to implement)
		fiber.unmount(root)
                eq({ "mounted", "unmounted" }, log, "the cleanup should run on unmount")
	end)

       it("runs effects in order and cleanups in reverse order", function()
		local log = {}

		local Test = ui.createComponent("Test", function()
			return function()
                                -- first effect
				useEffect(function()
					log[#log + 1] = "effect1"
					return function()
						log[#log + 1] = "cleanup1"
					end
				end)

                                -- second effect
				useEffect(function()
					log[#log + 1] = "effect2"
					return function()
						log[#log + 1] = "cleanup2"
					end
				end)

				return { Element:new({ content = "foo" }):wrap() }
			end
		end, {})

                -- initial mount
		local _, root = fiber.render(Test)
                eq({ "effect1", "effect2" }, log, "Effects must run in the declared order")

                -- generic rerender (no deps, so both effects always run again)
		log = {}
		fiber.rerender(root)
		eq(
			{ "cleanup2", "cleanup1", "effect1", "effect2" },
			log,
                        "Cleanups run in reverse order, then effects in order"
		)
	end)
end)
