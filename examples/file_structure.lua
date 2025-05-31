local Tree = require("ascii-ui.components.tree")
local ui = require("ascii-ui")

local tree = {
	text = "./",
	children = {
		{
			text = "node_modules",
			expanded = false,
			children = { { text = "node-1-3-1", children = { { text = "node-1-3-1-1" } } } },
		},
		{ text = "src", children = { { text = "main.js" } } },
		{ text = ".gitignore" },
		{ text = "package.json" },
	},
}

--- @type ascii-ui.FunctionalComponent
local function App()
	return function()
		return Tree({ tree = tree })
	end
end

ui.mount(App())
