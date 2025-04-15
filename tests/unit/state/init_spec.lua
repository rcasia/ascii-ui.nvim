pcall(require, "luacov")
local eq = assert.are.same

describe("uiX.state", function()
	local ui = {}

	function ui.state(initial)
		local value = vim.deepcopy(initial)
		local watchers = {}

		return {
			get = function()
				return value
			end,
			set = function(new_value)
				value = new_value
				for _, fn in ipairs(watchers) do
					fn(value)
				end
			end,
			watch = function(fn)
				table.insert(watchers, fn)
				fn(value)
			end,
			bind = function(key)
				return {
					get = function()
						return value[key]
					end,
					set = function(val)
						value[key] = val
						for _, fn in ipairs(watchers) do
							fn(value)
						end
					end,
				}
			end,
		}
	end

	it("returns initial state", function()
		local state = ui.state({ count = 0 })
		eq({ count = 0 }, state.get())
	end)

	it("updates state and notifies watchers", function()
		local state = ui.state({ enabled = false })

		local called = {}
		state.watch(function(v)
			table.insert(called, v.enabled)
		end)

		state.set({ enabled = true })
		eq({ false, true }, called)
	end)

	it("bind returns accessors to single key", function()
		local state = ui.state({ mode = "dark", level = 1 })
		local mode = state.bind("mode")

		eq("dark", mode.get())
		mode.set("light")
		eq("light", mode.get())
		eq({ mode = "light", level = 1 }, state.get())
	end)

	it("triggers watchers on bind set", function()
		local state = ui.state({ value = 100 })
		local triggered = {}

		state.watch(function(v)
			table.insert(triggered, v.value)
		end)

		local v = state.bind("value")
		v.set(200)

		eq({ 100, 200 }, triggered)
	end)
end)
