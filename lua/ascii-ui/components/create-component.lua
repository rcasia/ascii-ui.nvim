pcall(require, "luacov")

local M = {}

---Creates a reusable UI component with optional prop validation.
---
---Overloads:
---  createComponent(render_fn)
---  createComponent(name, render_fn)
---  createComponent(name, render_fn, prop_types)
---
---@param name_or_fn string|function
---@param render_fn_or_nil function|nil
---@param prop_types table|nil A flat map of { key = "type" } for prop validation.
---@return function
function M.create(name_or_fn, render_fn_or_nil, prop_types)
	local name, render_fn

	if type(name_or_fn) == "string" then
		name = name_or_fn
		render_fn = render_fn_or_nil
	else
		name = "AnonymousComponent"
		render_fn = name_or_fn
	end

	local validate_props
	if prop_types then
		validate_props = function(props)
			for key, expected_type in pairs(prop_types) do
				if props[key] ~= nil and type(props[key]) ~= expected_type then
					error(
						string.format(
							"%s: invalid prop '%s': expected %s, got %s",
							name,
							key,
							expected_type,
							type(props[key])
						)
					)
				end
			end
		end
	end

	return function(props)
		props = props or {}

		if validate_props then
			validate_props(props)
		end

		return {
			type = name,
			props = props,
			render = render_fn,
		}
	end
end

return M
