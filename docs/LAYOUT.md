# Layout

Layout primitives let you arrange components horizontally and vertically. ascii-ui.nvim provides two layout components: `Row` and `Column`.

## Row

Arranges children **horizontally** (side by side).

```lua
local Row = ui.layout.Row
local Paragraph = ui.components.Paragraph

Row(
    Paragraph({ content = "Left" }),
    Paragraph({ content = "Center" }),
    Paragraph({ content = "Right" })
)
```

### Calling Styles

Row supports two calling conventions:

**Varargs (simple):**
```lua
Row(child1, child2, child3)
```

**Props table (with options):**
```lua
Row({
    children = { child1, child2, child3 },
    gap = 2,
})
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `children` | `FiberNode[]` | `{}` | Array of child components to lay out. |
| `gap` | `integer\|nil` | `0` | Number of spaces between children. |

### Examples

**Basic horizontal layout:**
```lua
local Row = ui.layout.Row
local Button = ui.components.Button
local Paragraph = ui.components.Paragraph

Row(
    Button({ label = "OK", on_press = function() end }),
    Button({ label = "Cancel", on_press = function() end }),
)
```

**With gap:**
```lua
Row({
    children = {
        Paragraph({ content = "Name:" }),
        Input({ placeholder = "Enter name..." }),
    },
    gap = 2,
})
```

---

## Column

Arranges children **vertically** (stacked).

```lua
local Column = ui.layout.Column
local Paragraph = ui.components.Paragraph

Column(
    Paragraph({ content = "Line 1" }),
    Paragraph({ content = "Line 2" }),
    Paragraph({ content = "Line 3" })
)
```

### Calling Styles

Column supports the same two calling conventions as Row:

**Varargs:**
```lua
Column(child1, child2, child3)
```

**Props table:**
```lua
Column({
    children = { child1, child2, child3 },
    gap = 1,
})
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `children` | `FiberNode[]` | `{}` | Array of child components to stack. |
| `gap` | `integer\|nil` | `0` | Number of blank lines between children. |

---

## Nesting Layouts

Row and Column can be nested to create complex layouts:

```lua
local Row = ui.layout.Row
local Column = ui.layout.Column
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button

-- A sidebar + main content layout
Row(
    Column(
        Paragraph({ content = "=== Sidebar ===" }),
        Button({ label = "Home" }),
        Button({ label = "Settings" }),
        Button({ label = "About" }),
    ),
    Column(
        Paragraph({ content = "=== Main Content ===" }),
        Paragraph({ content = "Welcome to the app!" }),
    ),
)
```

### Dashboard Example

```lua
local ui = require("ascii-ui")
local Row = ui.layout.Row
local Column = ui.layout.Column
local Paragraph = ui.components.Paragraph
local Box = ui.components.Box
local Slider = ui.components.Slider
local useState = ui.hooks.useState

local Dashboard = ui.createComponent("Dashboard", function()
    local volume, setVolume = useState(50)
    local brightness, setBrightness = useState(70)

    return {
        Paragraph({ content = "=== Dashboard ===" }),
        Paragraph({ content = "" }),
        Row(
            Column(
                Box({ width = 20, height = 3, content = "CPU: 45%" }),
                Box({ width = 20, height = 3, content = "RAM: 62%" }),
            ),
            Column(
                Slider({
                    title = "Volume",
                    value = volume,
                    on_change = setVolume,
                }),
                Slider({
                    title = "Brightness",
                    value = brightness,
                    on_change = setBrightness,
                }),
            ),
        ),
    }
end)

ui.mount(Dashboard)
```

---

## Layout with Lists

Combine `Row`/`Column` with `ui.map` for dynamic layouts:

```lua
local items = { "Apple", "Banana", "Cherry", "Date" }

-- Horizontal list of items
Row(unpack(ui.map(items, function(item)
    return Paragraph({ content = item })
end)))

-- Vertical list with gap
Column({
    children = ui.map(items, function(item)
        return Paragraph({ content = "- " .. item })
    end),
    gap = 1,
})
```

---

## How Layout Works

Layout components create special `FiberNode` entries with a `layout` property:

- `Row` sets `layout = { direction = "row" }`
- `Column` sets `layout = { direction = "column" }`

The layout engine processes these during rendering to arrange children accordingly. Children are rendered in order, with optional gaps between them.

### Rendering Order

- **Row**: children are placed left-to-right, top-aligned
- **Column**: children are placed top-to-bottom, left-aligned

### Gap Behavior

- `gap = 0` (default): children are adjacent with no spacing
- `gap = N`: N spaces (Row) or N blank lines (Column) between each pair of children
