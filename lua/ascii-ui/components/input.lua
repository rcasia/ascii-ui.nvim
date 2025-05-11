local ui = require("ascii-ui")
local useState = ui.hooks.useState
local Element = require("ascii-ui.buffer.element")
local Bufferline = require("ascii-ui.buffer.bufferline")
local logger = require("ascii-ui.logger")

--- @alias ascii-ui.InputProps { value?: string }

--- @param props? ascii-ui.InputProps
--- @return fun(): ascii-ui.BufferLine[]
return ui.createComponent("Input", function(props)
	props = props or {}
	props.value = props.value or ""

	local value, setValue = useState(props.value)

	return function()
		return {
			Bufferline:new(
				Element:new({
					is_focusable = true,
					content = value(),
					interactions = {
						ON_INPUT = function(change)
							logger.debug("Input text changed: %s", change)
							setValue(change)
						end,
					},
				}),
				Element:new({
					content = "",
					is_focusable = true,
					interactions = {
						ON_INPUT = function(change)
							logger.debug("Input text changed: %s", change)
							setValue(change)
						end,
					},
				})
			),
		}
	end
end)
