local ui = require("ascii-ui")

--- @type ascii-ui.FunctionalComponent
local function App()
	return function()
		return [[

		<Layout>
			<Paragraph content="Hello World" />
			<Layout>
				<Button label="Click me" />
			</Layout>
		</Layout>

		]]
	end
end

ui.mount(App())
