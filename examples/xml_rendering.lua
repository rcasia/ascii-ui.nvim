local ui = require("ascii-ui")

local App = ui.createComponent("App", function()
	local value, set_value = ui.hooks.useState(0)
	local ref = ui.hooks.useFunctionRegistry(function()
		set_value(value + 1)
	end)

	return ([[

		<Column>
			<Paragraph content="Button Clicked %d times!" />
			<Button label="Click me" on_press="%s" />
		</Column>

		]]):format(value, ref)
end)

ui.mount(App)
