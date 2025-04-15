--- @alias ascii-ui.StateWatcher fun(state: table): nil
--- @class ascii-ui.BoundState
--- @field get fun(): any
--- @field set fun(value: any): nil

--- @class ascii-ui.ReactiveState
--- @field get fun(): table
--- @field set fun(new_value: table): nil
--- @field watch fun(fn: ascii-ui.StateWatcher): nil
--- @field bind fun(key: string): ascii-ui.BoundState

local State = {}

--- Creates a reactive state object.
-- The state allows global or key-specific access, supports watchers for changes.
--- @param initial table The initial state value
--- @return ascii-ui.ReactiveState A reactive state instance
function State.state(initial)
	local value = vim.deepcopy(initial)
	local watchers = {}

	--- @return table
	local function get()
		return value
	end

	--- @param new_value table
	local function set(new_value)
		value = new_value
		for _, fn in ipairs(watchers) do
			fn(value)
		end
	end

	--- @param fn ascii-ui.StateWatcher
	local function watch(fn)
		table.insert(watchers, fn)
		fn(value)
	end

	--- @param key string
	--- @return ascii-ui.BoundState
	local function bind(key)
		return {
			--- @return any
			get = function()
				return value[key]
			end,
			--- @param val any
			set = function(val)
				value[key] = val
				for _, fn in ipairs(watchers) do
					fn(value)
				end
			end,
		}
	end

	return {
		get = get,
		set = set,
		watch = watch,
		bind = bind,
	}
end

return State
