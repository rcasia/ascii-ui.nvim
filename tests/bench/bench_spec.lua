pcall(require, "luacov")

-- Silence all framework logs so they don't pollute benchmark output.
require("ascii-ui.logger").set_level("QUIET")

-- Performance benchmarks for ascii-ui.nvim
--
-- Each benchmark runs a hot path N times and reports:
--   min / avg / max  in milliseconds
--
-- A hard budget (ms) is asserted so CI catches regressions.
-- Budgets are intentionally generous to survive slow CI runners
-- (ubuntu-latest, macos-latest, windows-latest, stable + nightly).

local Segment = require("ascii-ui.buffer.segment")
local fiber = require("ascii-ui.fiber")
local ui = require("ascii-ui")
local useState = ui.hooks.useState

-- ─────────────────────────────────────────────────────────────
-- helpers
-- ─────────────────────────────────────────────────────────────

---Runs `fn` `n` times and returns { min, avg, max } in ms.
---@param n integer
---@param fn fun()
---@return { min: number, avg: number, max: number }
local function timeit(n, fn)
	local total = 0
	local min_ns = math.huge
	local max_ns = 0

	for _ = 1, n do
		local t0 = vim.uv.hrtime()
		fn()
		local elapsed = vim.uv.hrtime() - t0
		total = total + elapsed
		if elapsed < min_ns then
			min_ns = elapsed
		end
		if elapsed > max_ns then
			max_ns = elapsed
		end
	end

	return {
		min = min_ns / 1e6,
		avg = (total / n) / 1e6,
		max = max_ns / 1e6,
	}
end

---Pretty-print a timeit result with a label.
---@param label string
---@param n integer  number of iterations
---@param r { min: number, avg: number, max: number }
local function report(label, n, r)
	print(string.format("[bench] %-42s  n=%-5d  min=%.3fms  avg=%.3fms  max=%.3fms", label, n, r.min, r.avg, r.max))
end

-- ─────────────────────────────────────────────────────────────
-- fixtures
-- ─────────────────────────────────────────────────────────────

-- A minimal leaf component (single Segment → single BufferLine).
local Leaf = ui.createComponent("BenchLeaf", function(props)
	props = props or {}
	return { Segment:new({ content = props.text or "hello" }):wrap() }
end, { text = "string" })

-- A flat list of N leaves rendered side by side via ui.map.
local function make_list_component(size)
	local items = {}
	for i = 1, size do
		items[i] = tostring(i)
	end
	return ui.createComponent("BenchList" .. size, function()
		return ui.map(items, function(item)
			return Leaf({ text = item })
		end)
	end)
end

-- A stateful component — used for rerender benchmarks.
local BenchStateful
local set_content_outside
BenchStateful = ui.createComponent("BenchStateful", function()
	local content, setContent = useState("initial")
	set_content_outside = setContent
	return { Segment:new({ content = content }):wrap() }
end)

-- ─────────────────────────────────────────────────────────────
-- benchmarks
-- ─────────────────────────────────────────────────────────────

describe("performance", function()
	-- ── 1. first render of a single leaf ──────────────────────
	it("first render — single leaf component", function()
		local N = 200
		local r = timeit(N, function()
			fiber.render(Leaf)
		end)
		report("first render / single leaf", N, r)

		-- budget: avg render of one leaf must stay under 5 ms
		assert(r.avg < 5, string.format("avg %.3fms exceeds 5ms budget", r.avg))
	end)

	-- ── 2. rerender with a state change ───────────────────────
	it("rerender — stateful component, state changes every cycle", function()
		local N = 200
		local root = fiber.render(BenchStateful)
		-- prime the hook (first rerender populates set_content_outside)
		fiber.rerender(root)

		local counter = 0
		local r = timeit(N, function()
			counter = counter + 1
			set_content_outside(tostring(counter))
			fiber.rerender(root)
		end)
		report("rerender / state change every cycle", N, r)

		-- budget: avg rerender must stay under 5 ms
		assert(r.avg < 5, string.format("avg %.3fms exceeds 5ms budget", r.avg))
	end)

	-- ── 3. rerender with NO state change (NONE path) ──────────
	it("rerender — no state change (NONE fast-path)", function()
		local N = 200
		local root = fiber.render(Leaf)
		fiber.rerender(root)

		local r = timeit(N, function()
			fiber.rerender(root)
		end)
		report("rerender / no state change (NONE)", N, r)

		-- budget: the NONE fast-path should be very cheap
		assert(r.avg < 2, string.format("avg %.3fms exceeds 2ms budget", r.avg))
	end)

	-- ── 4. get_buffer — tree walk ──────────────────────────────
	it("get_buffer — tree walk after render", function()
		local N = 200
		local List20 = make_list_component(20)
		local root = fiber.render(List20)

		local r = timeit(N, function()
			root:get_buffer()
		end)
		report("get_buffer / 20-leaf tree", N, r)

		-- budget: collecting lines from a 20-node tree must stay under 5 ms
		assert(r.avg < 5, string.format("avg %.3fms exceeds 5ms budget", r.avg))
	end)

	-- ── 5. render — wider flat tree (stress) ──────────────────
	it("first render — flat list of 50 leaves", function()
		local N = 50
		local List50 = make_list_component(50)

		local r = timeit(N, function()
			fiber.render(List50)
		end)
		report("first render / 50-leaf list", N, r)

		-- budget: 50 leaves must render in under 100 ms on average
		-- (component creation + memoize key gen is expensive; this is a stress test)
		assert(r.avg < 100, string.format("avg %.3fms exceeds 100ms budget", r.avg))
	end)

	-- ── 6. reconcileChildren — repeated diffing ────────────────
	it("reconcileChildren — repeated child diffing", function()
		local N = 500

		-- Build real component fiber nodes (with closures) so is_same works correctly.
		local children = {}
		for i = 1, 10 do
			local comp = ui.createComponent("BenchChild" .. i, function()
				return { Segment:new({ content = "item" .. i }):wrap() }
			end)
			children[i] = comp()
		end

		-- Render so child nodes are fully initialised (have output / child links).
		local parent = ui.createComponent("BenchParent10", function()
			return children
		end)
		local root = fiber.render(parent)

		local r = timeit(N, function()
			fiber.reconcileChildren(root, children)
		end)
		report("reconcileChildren / 10 children", N, r)

		-- budget: diffing 10 children must stay under 5 ms on average
		assert(r.avg < 5, string.format("avg %.3fms exceeds 5ms budget", r.avg))
	end)
end)
