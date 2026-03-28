<img align="right" width="100px" src="./logo.png" alt="Ascii-UI Logo" />

[![Test](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/test.yml)
[![Lux Publish](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/publish-to-luarocks.yml/badge.svg)](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/publish-to-luarocks.yml)
[![Docs](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/check-docs.yml/badge.svg)](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/check-docs.yml)

# ascii-ui.nvim

A reactive, component-based UI framework for building interactive ASCII interfaces inside Neovim — or in your terminal via stdout.

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

---

## Features

- **Component model** — compose UIs from small, reusable components with `ui.createComponent`
- **Reactive state** — `useState`, `useReducer`, `useEffect`, `useInterval`, `useTimeout`, `useConfig`
- **Built-in components** — `Button`, `Paragraph`, `Select`, `Slider`, `Checkbox`, `Input`, `Box`, `Tree`
- **Keyboard navigation** — `h`/`j`/`k`/`l` to move focus, `<CR>` to interact, `q` to close
- **Multiple viewports** — Neovim floating window (default) or `StdoutViewport` for terminal/headless rendering
- **List utilities** — `ui.map` for rendering collections

---

## Requirements

- Neovim 0.11+

---

## Installation

Using **lazy.nvim**:

```lua
return {
  "rcasia/ascii-ui.nvim",
  opts = {},
}
```

---

## Usage

```lua
local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useState = ui.hooks.useState

local App = ui.createComponent("App", function()
  local content, setContent = useState("Hello, ascii-ui!")

  return {
    Paragraph({ content = content }),
    Button({
      label = "Change",
      on_press = function()
        setContent("State updated!")
      end,
    }),
  }
end)

ui.mount(App)
```

Mount inside a Neovim command or keybind:

```lua
vim.keymap.set("n", "<leader>ui", function()
  ui.mount(App)
end)
```

### Stdout / headless rendering

Render to the terminal instead of a Neovim window using `StdoutViewport`:

```lua
ui.mount(App, ui.viewports.StdoutViewport.new())
```

---

## Components

| Component   | Description                              |
|-------------|------------------------------------------|
| `Paragraph` | Renders a single line of text            |
| `Button`    | Focusable, pressable button              |
| `Select`    | Dropdown / option selector               |
| `Slider`    | Numeric range slider                     |
| `Checkbox`  | Toggle checkbox                          |
| `Input`     | Text input field                         |
| `Box`       | Container for layout and grouping        |
| `Tree`      | Collapsible tree view                    |

---

## Hooks

| Hook           | Description                                      |
|----------------|--------------------------------------------------|
| `useState`     | Local reactive state                             |
| `useReducer`   | State with a reducer function                    |
| `useEffect`    | Side effects and cleanup on mount/unmount        |
| `useInterval`  | Recurring timer                                  |
| `useTimeout`   | One-shot timer                                   |
| `useConfig`    | Access the global ascii-ui configuration         |

---

## Keyboard bindings

These bindings are active while the ascii-ui window is focused:

| Key    | Action                                        |
|--------|-----------------------------------------------|
| `h`    | Move focus left / to the previous element     |
| `l`    | Move focus right / to the next element        |
| `k`    | Move focus up                                 |
| `j`    | Move focus down                               |
| `<CR>` | Trigger the focused element (select/press)    |
| `q`    | Close the window                              |

---

## Examples

The [`examples/`](./examples) directory contains ready-to-run demos:

- `example-1.lua` — basic state + button
- `analog-clock.lua` — real-time clock with `useInterval`
- `animated-bar-chart.lua` — animated chart
- `file_structure.lua` — file tree with the `Tree` component
- `train-station-board.lua` — scrolling departure board
- `metro-map.lua` — ASCII map rendering
- `stdout-animated.lua` — headless animated output via `StdoutViewport`

Run any example directly:

```bash
nvim -c "luafile examples/example-1.lua"
```

---

## Documentation

Full API reference, component docs, and guides:
**https://rcasia.github.io/ascii-ui-docs/**
