local createComponent = require("ascii-ui.components.create-component")
local Paragraph = require("ascii-ui.components.paragraph")

return createComponent("DebugFixture", function()
	return { Paragraph({ content = "debug fixture loaded" }) }
end)
