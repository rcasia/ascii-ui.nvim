<img align="right" width="100px" src="./logo.png" alt="Ascii-UI Logo" />

[![Test](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/test.yml)
[![Lux Publish](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/publish-to-luarocks.yml/badge.svg)](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/publish-to-luarocks.yml)
[![Docs](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/check-docs.yml/badge.svg)](https://github.com/rcasia/ascii-ui.nvim/actions/workflows/check-docs.yml)

# ascii-ui.nvim

**Build rich, interactive UIs for your Neovim plugins — with React-like components, hooks, and a fiber-based reconciler.**

ascii-ui.nvim is a complete UI framework for Neovim. Write functional components, manage state with hooks, compose layouts, and render to floating windows or terminal stdout. No more wrestling with raw `nvim_buf_set_lines` calls.

## Features

- **React-like component model** — functional components with props, composition, and reconciliation
- **Hooks** — `useState`, `useEffect`, `useReducer`, `useInterval`, `useTimeout`, `useConfig`
- **Built-in components** — Button, Input, Select, Slider, Checkbox, Tree, Box, Paragraph
- **Layout primitives** — `Row` and `Column` for horizontal and vertical arrangement
- **Fiber-based reconciler** — efficient tree diffing and minimal re-renders
- **Multiple viewports** — Neovim floating windows (default), terminal stdout, or custom
- **Live reload** — instant feedback during development with `make debug`
- **ANSI truecolor** — full color support via the `Color` class and segment colors
- **Zero dependencies** — pure Lua, runs on Neovim's embedded Lua 5.1

## Quick Start

### Installation

**[lazy.nvim](https://github.com/folke/lazy.nvim):**

```lua
return {
    "rcasia/ascii-ui.nvim",
    opts = {},
}
```

**[luarocks](https://luarocks.org/):**

```bash
luarocks install ascii-ui
```

**[lux](https://github.com/lux-cli/lux):**

```bash
lux install ascii-ui
```

### Hello World

```lua
local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local useState = ui.hooks.useState

local App = ui.createComponent("App", function()
    local count, setCount = useState(0)
    return {
        Paragraph({ content = "Count: " .. count }),
        Button({
            label = "+1",
            on_press = function()
                setCount(count + 1)
            end,
        }),
    }
end)

ui.mount(App)
```

That's it. A floating window opens with a counter and a button. Click the button, the count updates. State management and rendering handled for you.

## What Can You Build?

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

From file explorers and dashboards to animated clocks and train station boards — if it can be drawn with text, ascii-ui.nvim can render it.

See the [`examples/`](./examples/) directory for more:

| Example | What it shows |
|---------|--------------|
| [`analog-clock.lua`](./examples/analog-clock.lua) | Animated clock with `useInterval` + `Color` |
| [`file_structure.lua`](./examples/file_structure.lua) | Collapsible tree with the `Tree` component |
| [`train-station-board.lua`](./examples/train-station-board.lua) | Scrolling text animation |
| [`animated-bar-chart.lua`](./examples/animated-bar-chart.lua) | Dynamic bar chart with state |
| [`metro-map.lua`](./examples/metro-map.lua) | ASCII art with colored segments |
| [`text-input.lua`](./examples/text-input.lua) | Form with `Input` component |
| [`select-dropdown.lua`](./examples/select-dropdown.lua) | Selectable list with `Select` |

## Documentation

| Guide | Description |
|-------|-------------|
| [**Components**](./docs/COMPONENTS.md) | Full reference for all built-in components with props and examples |
| [**Hooks**](./docs/HOOKS.md) | State management, side effects, timers — the full hooks API |
| [**Layout**](./docs/LAYOUT.md) | `Row` and `Column` for arranging components |
| [**Advanced**](./docs/ADVANCED.md) | Custom components, viewports, low-level rendering (Segment, BufferLine, Buffer) |
| [**API Reference**](https://rcasia.github.io/ascii-ui-docs/) | Full generated documentation |

## Configuration

```lua
require("ascii-ui").setup({
    log_level = "INFO",
    characters = {
        top_left = "╭", top_right = "╮",
        bottom_left = "╰", bottom_right = "╯",
        horizontal = "─", vertical = "│",
        left_tree = "├", thumb = "●",
        whitespace = " ", right_triangule = "▸", down_triangule = "▾",
    },
    keymaps = {
        quit = "q",
        select = "<CR>",
    },
})
```

## Live Reload

> **Experimental:** This feature is under active development and the API may change.

ascii-ui.nvim ships a live-reload debug mode. Save any `.lua` file and the running Neovim instance automatically tears down the current UI, unloads all modules, and re-executes your script.

**Requirements:** `nvim` on `$PATH`.

### Quick start

1. Write your component in any `.lua` file and return it:

```lua
-- lua/myplugin/MyComp.lua
local ui = require("ascii-ui")
local useState = ui.hooks.useState
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button

return ui.createComponent("MyComp", function()
    local count, setCount = useState(0)
    return {
        Paragraph({ content = "count: " .. count }),
        Button({ label = "+1", on_press = function() setCount(count + 1) end }),
    }
end)
```

2. Create a `debug.lua` in the repository root:

```lua
require("ascii-ui").debug("lua/myplugin/MyComp.lua")
```

3. Start the session:

```sh
make debug
```

Every save reloads the UI automatically. Errors are shown as notifications without crashing the session.

Works from any running Neovim session too:

```
:lua require("ascii-ui").debug("lua/myplugin/MyComp.lua")
```

## AI Agent Skill

Use ascii-ui.nvim with AI coding agents (OpenCode, Claude, etc.) by installing the official agent skill:

```sh
npx skills add rcasia/agent-skills --skill ascii-ui-nvim
```

The skill gives agents a mental model of the component system, hooks, and common patterns so they can generate correct ascii-ui code without hallucinating APIs. Source: [rcasia/agent-skills](https://github.com/rcasia/agent-skills).

## Development

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/rcasia/ascii-ui.nvim.git
   cd ascii-ui.nvim
   ```

2. Install dependencies:
   - [lux](https://github.com/lux-cli/lux) (Lua package manager)
   - [stylua](https://github.com/JohnnyMorganz/StyLua) (Lua formatter)
   - [luacheck](https://github.com/lunarmodules/luacheck) (Lua linter, via lux)
   - [pre-commit](https://pre-commit.com/) (git hooks framework)
   - [yq](https://github.com/mikefarah/yq) (YAML processor, for workflow validation)

3. Install pre-commit hooks:
   ```bash
   pre-commit install --hook-dir .githooks
   ```

### Commands

| Command | Purpose |
|---|---|
| `make test` | Run full test suite |
| `make check` | Run lint, format check, docs check |
| `make docs` | Regenerate vimdocs from Lua annotations |
| `make debug` | Live-reload debug session |
| `pre-commit run --all-files` | Run all pre-commit hooks manually |

## License

MIT
