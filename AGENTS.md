# AGENTS.md

> **Agentic Development**: Since August 8, 2026, this project uses a multi-agent system for development. See `.opencode/agents/` for specialized agents (ascii-ui-dev, nvim-docs-researcher, convention-reviewer, agent-teacher).

## Commit Convention

All commits must specify which agent is acting using the format:

```
type(agent): description

[agent: agent-name]
```

### Agent Identifiers

- `ascii-ui-dev` - Primary development agent
- `nvim-docs-researcher` - Documentation research agent
- `convention-reviewer` - Convention validation agent
- `agent-teacher` - Meta-learning agent

### Examples

```
feat(ascii-ui-dev): add new Input component

[agent: ascii-ui-dev]
```

```
docs(nvim-docs-researcher): document vim.api.nvim_open_win behavior

[agent: nvim-docs-researcher]
```

```
chore(convention-reviewer): update review checklist for hooks

[agent: convention-reviewer]
```

```
refactor(agent-teacher): improve agent consulting patterns

[agent: agent-teacher]
```

### Commit Types

- `feat` - New features
- `fix` - Bug fixes
- `docs` - Documentation changes
- `refactor` - Code refactoring
- `test` - Test additions/changes
- `chore` - Maintenance tasks
- `perf` - Performance improvements

## Project Overview

ascii-ui.nvim is a React-like UI framework for Neovim plugins, written in Lua. It provides functional components, hooks (`useState`, `useEffect`, `useReducer`, etc.), a fiber-based reconciler, built-in components (`Paragraph`, `Button`, `Box`, `Select`, `Slider`, `Checkbox`, `Tree`, `Input`), and layout primitives (`Row`). Components render to Neovim floating windows or terminal stdout.

## Commands

| Command | Purpose |
|---|---|
| `make test` | Build + run full test suite |
| `make test path/to/file_spec.lua` | Run a single test file |
| `make check` | Lint (luacheck via lux), format check (stylua), docs check |
| `make docs` | Regenerate vimdocs from Lua annotations |
| `make bench` | Run performance benchmarks |
| `make debug` | Live-reload debug session |

**Always run `make check` and `make test` after making changes.**

## Architecture

### Source layout

All source lives under `lua/ascii-ui/`. Modules are required with full dotted paths: `require("ascii-ui.buffer.segment")`.

```
lua/ascii-ui/
├── init.lua              # Public API
├── buffer/               # Buffer rendering primitives (Segment, BufferLine, Buffer)
├── components/           # Built-in components (Paragraph, Button, Box, Select, etc.)
├── hooks/                # React-like hooks (useState, useEffect, useReducer, etc.)
├── layout/               # Layout primitives (Row)
├── utils/                # Utility modules
├── viewports/            # Viewport implementations (StdoutViewport)
├── window/               # Neovim floating window viewport
├── fiber.lua             # Fiber reconciler
├── fibernode.lua         # Fiber tree node
├── mount.lua             # Component mounting + render loop
├── events.lua            # EventBus
├── config.lua            # Default config
└── ...
```

### Test layout

Tests mirror source structure under `tests/`:

```
tests/
├── unit/                 # Unit tests (mirror lua/ascii-ui/ structure)
│   ├── components/       # Component tests
│   └── hooks/            # Hook tests
├── e2e/                  # End-to-end interaction tests
├── bench/                # Benchmarks with hard budget assertions
└── util/                 # Test fixtures and helpers
```

### Key modules

- **`fiber.lua` / `fibernode.lua`** — React-like fiber reconciler. Depth-first tree traversal, reconciliation, diffing.
- **`mount.lua`** — Mounts components to viewports, manages the render loop.
- **`buffer/`** — `Segment` (styled text unit), `BufferLine` (line of segments), `Buffer` (collection of lines).
- **`components/`** — Each component in its own file, registered via `createComponent(name, fn, types)`.
- **`hooks/`** — Each hook in its own file. Follow React naming: `useState`, `useEffect`, etc.

## Conventions

### Code style

- **Formatter**: StyLua (config in `.stylua.toml`) — tabs, width 4, double quotes, collapse simple statements off
- **Linter**: luacheck (config in `.luacheckrc`)
- **Type annotations**: LuaCATS/LuaLS format, extensive use of `@class`, `@field`, `@param`, `@return`, `@enum`
- **Type prefix**: `ascii-ui.` for all type annotations (e.g., `ascii-ui.Segment`, `ascii-ui.Config`)

### Naming

- **Filenames**: `snake_case.lua` (components use hyphens in `create-component.lua` — outlier)
- **Classes**: PascalCase (`FiberNode`, `Buffer`, `Segment`, `Window`, `EventBus`)
- **Components**: PascalCase strings (`"Paragraph"`, `"Button"`, `"Select"`)
- **Hooks**: camelCase (`useState`, `useEffect`, `useReducer`)
- **Test files**: `*_spec.lua`

### Module pattern

Every class/module follows this structure:

```lua
local ModuleName = {}
ModuleName.__index = ModuleName

function ModuleName.new(opts)
    local state = { ... }
    setmetatable(state, ModuleName)
    return state
end

function ModuleName.is_module(obj)
    return type(obj) == "table" and obj.__index == ModuleName.__index
end

return ModuleName
```

### Component pattern

```lua
local createComponent = require("ascii-ui.utils.create-component")

local function MyComponent(props)
    return { Segment:new({ content = props.text }):wrap() }
end

return createComponent("MyComponent", MyComponent, { text = "string" })
```

Components return arrays of `FiberNode` or `BufferLine` objects. Use `Segment:wrap()` to wrap a segment in a `BufferLine`.

### Subdirectory `init.lua` pattern

Directories with multiple files expose an `init.lua` that re-exports the public API (e.g., `buffer/init.lua`, `components/init.lua`, `hooks/init.lua`).

## Testing

- **Framework**: Plenary.nvim test harness (Busted-style `describe`/`it`/`assert`)
- **Assertions**: `luassert` — `assert.are.same`, `assert.is_true`, etc.
- **Every test file** must start with `pcall(require, "luacov")` (enforced by `tests/arch_spec.lua`)
- **E2E tests** use `plenary.async.tests.it` for async testing
- **Benchmarks** have hard budget assertions to catch performance regressions

## Documentation

- Vimdocs (`doc/ascii-ui.txt`) are auto-generated from Lua annotations via `mini.doc`
- Run `make docs` after changing public API annotations
- Run `make docs-check` to verify docs are up to date (part of `make check`)

## Dependencies

- **Package manager**: Lux (`lux.toml`)
- **Runtime**: Lua 5.1 (Neovim's embedded Lua)
- **Test dependency**: `plenary.nvim` (cloned automatically by `scripts/test`)
- **Dev tools**: `stylua`, `luacheck`, `nvim`, `git`
