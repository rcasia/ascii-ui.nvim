# AGENTS.md

> **Agentic Development**: Since August 8, 2026, this project uses a multi-agent system for development. See `.opencode/agents/` for specialized agents (ascii-ui-dev, nvim-docs-researcher, convention-reviewer, agent-teacher).

## Commit Convention

All commits must follow conventional commits and specify which agent is acting in the footer:

```
type(scope): description

[agent: agent-name]
```

- `type` — conventional commit type (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`)
  - `refactor` — only for code restructuring (imports, folders, code organization), not for docs or agent changes
- `scope` — area of the codebase affected (e.g., `components`, `hooks`, `fiber`, `agents`, `buffer`)
- `[agent: agent-name]` — footer identifying which agent made the commit

### Agent Identifiers

- `ascii-ui-dev` - Primary development agent
- `nvim-docs-researcher` - Documentation research agent
- `convention-reviewer` - Convention validation agent
- `agent-teacher` - Meta-learning agent

### Examples

```
feat(components): add new Input component

[agent: ascii-ui-dev]
```

```
docs(hooks): document useEffect cleanup behavior

[agent: nvim-docs-researcher]
```

```
chore(agents): update review checklist for hooks

[agent: convention-reviewer]
```

```
chore(agents): improve agent consulting patterns

[agent: agent-teacher]
```

**Note**: All agent-related changes (updates to agent files, conventions, or configuration) must use `chore` type with `agents` scope.

### Issue References

When a commit is related to an issue, reference it in the commit message:

```
feat(components): add Input component with validation

Closes #42

[agent: ascii-ui-dev]
```

Use keywords: `Closes #123`, `Fixes #123`, `Resolves #123`

## Trunk-Based Development

This project follows trunk-based development. All work happens on `main` branch directly.

### Rules

1. **Tests must pass** - Never commit if tests are failing
2. **No --no-verify** - Always run pre-commit hooks
3. **Small commits** - Keep changes atomic and focused
4. **Pull before push** - Always `git pull` before pushing
5. **Red pipeline = STOP** - If main pipeline is red, all agents stop current work
6. **Commit ASAP** - Commit the minimal significant change as soon as it works
7. **TDD first** - Write tests first, then implement (red-green-refactor)

### Commit ASAP

Commit as soon as you have a minimal significant change working with its tests:
- Don't accumulate large changes
- One feature/fix per commit
- Include tests with the change
- If it works and has tests, commit it

### TDD Workflow (Baby Steps)

Follow test-driven development with small incremental steps:

1. **Red** - Write a failing test for the smallest possible behavior
2. **Green** - Write the minimal code to make the test pass
3. **Refactor** - Clean up while tests still pass
4. **Repeat** - Add the next small behavior

**Baby steps means:**
- One assertion at a time
- One function at a time
- Don't skip ahead or implement multiple things at once
- Let the tests guide the design

### When Pipeline is Red

**CRITICAL**: If the main branch pipeline is failing:

1. **All agents stop** - Pause whatever you're doing
2. **One agent fixes** - Designate one agent to investigate and fix the issue
3. **No new features** - Do not commit new code until pipeline is green
4. **Priority #1** - Fixing the pipeline takes precedence over all other work

**Workflow when pipeline is red:**
```bash
# Check if main is failing
git checkout main
git pull
make test

# If tests fail:
# 1. All agents stop their current tasks
# 2. ascii-ui-dev (or designated agent) investigates
# 3. Fix the issue on main (or WIP branch if complex)
# 4. Verify tests pass
# 5. Only then resume normal work
```

### When Tests Fail

If you need to commit work but tests are failing:
- **Do NOT** use `--no-verify` to bypass hooks
- **Do NOT** commit to main with failing tests
- **Instead**: Create a draft PR or WIP branch
  - `git checkout -b wip/feature-name`
  - Push the branch
  - Open a draft PR for review
  - Fix tests before merging to main

### Workflow

```bash
# Standard workflow
git pull --rebase
# Make changes
make check
make test
git add .
git commit -m "type(scope): description\n\n[agent: agent-name]"
git push

# If tests fail, use a WIP branch
git checkout -b wip/broken-feature
git push -u origin wip/broken-feature
# Open draft PR on GitHub
```

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
