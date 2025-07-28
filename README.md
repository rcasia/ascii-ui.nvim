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

## API example

```lua

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Column = ui.layout.Column
local Button = ui.components.Button
local useState = ui.hooks.useState

local App = ui.createComponent("App", function()
  local content, setContent = useState("initial content")
  return {
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

## 🔹 Minimal Example

<p align="center">
  <img width="90%" alt="image" align="center" src="https://github.com/user-attachments/assets/aacb716f-34ff-4c2b-b064-21994d23fe33" />
</p>


<details>
<summary>📜 See code snippet</summary>

```lua
local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Column = ui.layout.Column
local Row = ui.layout.Row
local Button = ui.components.Button
local useState = ui.hooks.useState

local App = ui.createComponent("App", function()
	local content, setContent = useState("initial content")
	local count, setCount = useState(0)

	return Column(
		Paragraph({ content = "📝 " .. content }),
		Row(
			Button({
				label = "[ Change Text ]",
				on_press = function()
					setContent("content changed at " .. os.date("%H:%M:%S"))
				end,
			}),
			Button({
				label = "[ +1 Counter ]",
				on_press = function()
					setCount(count + 1)
				end,
			})
		),
		Paragraph({ content = "🔢 Counter: " .. count })
	)
end)

ui.mount(App)
```

</details>

