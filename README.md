<img align="right" width="100px" src="./logo.png" alt="Ascii-UI Logo" />

[![Test](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/test.yml)
[![Lux Publish](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/publish-to-luarocks.yml/badge.svg)](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/publish-to-luarocks.yml)
[![Docs](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/check-docs.yml/badge.svg)](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/check-docs.yml)

# ascii-ui.nvim

A WIP extensible ui framework with no non-sense apis (hopefully) for nvim.

React-style components and hooks, but in Lua, inside your editor. check out the [docs](https://rcasia.github.io/ascii-ui-docs/) to learn more.

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

local App = ui.createComponent("App", function(props)
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

## Components

| Component | Description |
|---|---|
| `Paragraph` | renders text, supports `\n` for multiple lines |
| `Button` | focusable button, fires `on_press` when selected |
| `Select` | scrollable list of options with a callback |
| `Slider` | horizontal 0–100 slider, step 10 |
| `Input` | editable text field |
| `Tree` | collapsible file/directory tree |
| `Box` | draws a rounded border box around content |
| `Row` | lays out components side by side horizontally |

## Hooks

| Hook | Description |
|---|---|
| `useState` | state primitive, triggers re-render on change |
| `useEffect` | run side effects after render, with optional deps |
| `useReducer` | `(state, action) -> state` reducer on top of useState |
| `useInterval` | repeating timer, cleans up automatically on unmount |
| `useTimeout` | one-shot timer, same deal |
| `useConfig` | read the global ascii-ui config |

also `ui.map(items, fn)` for rendering lists of components without losing your mind.
