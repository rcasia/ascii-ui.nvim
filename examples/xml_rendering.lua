local ui = require("ascii-ui")
local useState = ui.hooks.useState

--- @type ascii-ui.FunctionalComponent
local function App()
	return function()
		-- return ui.layout(ui.components.Slider())
		return [[

		 <Paragraph content="devs" />

		]]
	end
end

ui.mount(App())
