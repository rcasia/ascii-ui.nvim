<img align="right" width="100px" src="./logo.png" alt="Ascii-UI Logo" />

[![Test](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/test.yml)
[![Lux Publish](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/publish-to-luarocks.yml/badge.svg)](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/publish-to-luarocks.yml)
[![Docs](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/check-docs.yml/badge.svg)](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/check-docs.yml)

# ascii-ui.nvim

A WIP extensible ui framework with no non-sense apis (hopefully) for nvim.

check out the [docs](https://rcasia.github.io/ascii-ui-docs/) to learn more.

## AI Agent Skill

Use ascii-ui.nvim with AI coding agents (OpenCode, Claude, etc.) by installing the official agent skill:

```sh
npx skills add rcasia/agent-skills --skill ascii-ui-nvim
```

The skill gives agents a mental model of the component system, hooks, and common patterns so they can generate correct ascii-ui code without hallucinating APIs. Source: [rcasia/agent-skills](https://github.com/rcasia/agent-skills).

<table align="center">
  <tr>
    <td><img src="https://github.com/user-attachments/assets/0d2729e1-1518-430f-93f1-e52755b6f347" height="250"></td>
    <td><img src="https://github.com/user-attachments/assets/1df3c920-0ced-46a0-90c7-97231ad33ba9" height="250"></td>
  </tr>
  <tr>
       <td><img src="https://github.com/user-attachments/assets/419ab99a-424a-46e5-bc1c-8f177cbef298" height="250"></td>
       <td><img src="https://github.com/user-attachments/assets/1e9ecc74-9e1a-4e67-b3c1-9d04b5c4755e" height="250"></td>
  </tr>
</table>

# Installation

```lua
return {
  { 
  "rcasia/ascii-ui.nvim", 
  opts = {}
 },
}
```

## Usage

```lua

local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useState = ui.hooks.useState

local App = ui.createComponent(function(props)
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
