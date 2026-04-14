# Contributing

## Setup

```sh
bash scripts/setup_dev
```

This configures the git hooks so `make check` and `make test` run automatically before each commit.

Dependencies: [lux](https://github.com/nvim-neorocks/lux), [StyLua](https://github.com/JohnnyMorganz/StyLua), [luacheck](https://github.com/lunarmodules/luacheck), [ast-grep](https://ast-grep.github.io/guide/quick-start.html).

## Running checks manually

```sh
make check   # luacheck + stylua + ast-grep
make test    # build + busted test suite
```

## Code style

- **Indentation**: tabs, width 4
- **Line width**: 120 columns
- **Quotes**: double-quoted strings preferred
- **Requires**: sorted alphabetically at the top of each file (enforced by StyLua)

## Type annotations

This project uses [LuaLS](https://luals.github.io/) annotations. Follow these conventions:

### Component prop types

Prop type aliases for components must follow the `ascii-ui.XxxComponent.Props` naming convention:

```lua
-- correct
--- @alias ascii-ui.ButtonComponent.Props { label: string, on_press?: fun() }

-- incorrect
---@alias ascii-ui.ButtonProps { ... }         -- missing "Component"
---@alias ascii-ui.ButtonComponentOpts { ... } -- "Opts" instead of "Props", no dot
---@alias ascii-ui.ButtonComponentProps { ... } -- missing dot separator
```

This is enforced by two ast-grep rules in `rules/`:

| Rule | What it flags |
|---|---|
| `component-prop-type-naming` | `@class`/`@alias` declarations not following `XxxComponent.Props` |
| `component-prop-param-naming` | `@param props` annotations referencing the non-canonical names |
| `no-print-statements` | `print()` calls in library source — use `logger.debug/info/warn/error` |

The rules run as part of `make check` and in the `Static Analysis` GitHub Actions workflow.

If a rule fires on a line that is genuinely correct (e.g. a local variable that shadows a flagged name), suppress it with an inline comment:

```lua
-- ast-grep-ignore: rule-id
the_flagged_line()
```

### Adding new ast-grep rules

Rules live in `rules/*.yml` and are picked up automatically via `sgconfig.yml`. Each file contains one rule. To add a new rule:

1. Create `rules/my-rule.yml` following the [ast-grep rule reference](https://ast-grep.github.io/reference/rule.html)
2. Test it locally: `ast-grep scan lua/ --error`
3. Include it in your PR

## Adding components

New components go in `lua/ascii-ui/components/`. Follow the existing pattern:

```lua
--- @alias ascii-ui.MyComponent.Props { ... }

--- @param props ascii-ui.MyComponent.Props
--- @return ascii-ui.BufferLine[]
local function MyComponent(props)
    props = props or {}
    -- ...
end

return createComponent("MyComponent", MyComponent, { prop_name = "type" })
```

A corresponding test file is expected at `tests/unit/components/my_component_spec.lua`.
