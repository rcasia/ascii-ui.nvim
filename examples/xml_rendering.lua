local ui = require("ascii-ui")

local App = ui.createComponent("App", function()
	local message, set_message = ui.hooks.useState("Hello World")
	local ref = ui.hooks.useFunctionRegistry(function()
		set_message("Button Clicked!")
	end)

	return function()
		return ([[

		<Layout>
			<Paragraph content="%s" />
			<Button label="Click me" on_press="%s" />
		</Layout>

		]]):format(message(), ref)
	end
end)

ui.mount(App)
