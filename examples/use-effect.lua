local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useState = ui.hooks.useState
local useEffect = ui.hooks.useEffect

local function App()
	local name, setName = useState("world")
	local greeting, setGreeting = useState("")

	useEffect(function()
		setGreeting("Hello, " .. name .. "!")
	end, { name })

	return {
		Paragraph({ content = greeting }),
		Button({
			label = "Change name",
			on_press = function()
				local names = { "Lua", "Neovim", "ascii-ui", "world" }
				local idx = math.random(#names)
				setName(names[idx])
			end,
		}),
	}
end

ui.mount(ui.createComponent("App", App))
