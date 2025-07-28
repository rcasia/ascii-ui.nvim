<img align="right" width="100px" src="./logo.png" alt="Ascii-UI Logo" />

[![codecov](https://codecov.io/gh/rcasia/ascii-ui.nvim/graph/badge.svg?token=J5ISORZOQF)](https://codecov.io/gh/rcasia/ascii-ui.nvim)

# ascii-ui.nvim

A WIP extensible ui framework with no non-sense apis (hopefully) for nvim.

```lua
return {
  { 
  "rcasia/ascii-ui.nvim", 
  opts = {}
 },
}
```

## Example

```lua

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Column = ui.layout.Column
local Button = ui.components.Button
local useState = ui.hooks.useState

local App = ui.createComponent("App", function()
  local content, setContent = useState("initial content")
  return {
   --
   Paragraph({ content = content }),
   Button({
    label = "change",
    on_press = function()
     setContent("changed content")
    end,
   })
  }
end)

ui.mount(App)

```
