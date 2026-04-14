local Paragraph = require("ascii-ui.components.paragraph")
local createComponent = require("ascii-ui.components.create-component")

return createComponent("DebugFixture", function()
	return { Paragraph({ content = "debug fixture loaded" }) }
end)
