local ui = require("ascii-ui")

local App = ui.createComponent("App", function()
	return function()
		local value, set_value = ui.hooks.useState(0)
		local ref = ui.hooks.useFunctionRegistry(function()
			set_value(value + 1)
		end)

		return ([[

		<Layout>
			<Paragraph content="Button Clicked %d times!" />
			<Button label="Click me" on_press="%s" />
		</Layout>

		]]):format(value, ref)
	end
end)

ui.mount(App)
