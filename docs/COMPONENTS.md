# Components Reference

ascii-ui.nvim provides a set of built-in components for common UI patterns. Each component is a function that accepts a props table and returns an array of renderable nodes.

All components are accessed via `ui.components.<Name>`.

## Paragraph

Renders text content. Automatically splits on newlines.

```lua
local Paragraph = ui.components.Paragraph

Paragraph({ content = "Hello, world!" })
Paragraph({ content = "Line 1\nLine 2\nLine 3" })
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `content` | `string` | `""` | Text to display. Newlines (`\n`) create multiple lines. |

---

## Button

A focusable, pressable button. Triggers `on_press` when the user presses Enter (or the configured select key).

```lua
local Button = ui.components.Button

Button({
    label = "Click me",
    on_press = function()
        print("Button pressed!")
    end,
})
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `label` | `string` | *(required)* | Text displayed on the button. |
| `on_press` | `function\|nil` | `nil` | Callback fired when the button is activated. |

### Behavior

- Buttons are **focusable** — navigate to them with Tab/Shift-Tab
- Press `<CR>` (or configured select key) to activate
- Styled with the `BUTTON` highlight group

---

## Input

A text input field. Supports both controlled and uncontrolled modes.

```lua
local Input = ui.components.Input
local useState = ui.hooks.useState

-- Uncontrolled (manages its own state)
Input({
    placeholder = "Type something...",
    on_submit = function(value)
        print("Submitted: " .. value)
    end,
})

-- Controlled (state managed by parent)
local MyForm = ui.createComponent("MyForm", function()
    local name, setName = useState("")
    return {
        Input({
            value = name,
            on_change = function(v) setName(v) end,
            on_submit = function(v) print("Hello, " .. v) end,
        }),
    }
end)
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `string\|nil` | `nil` | Controlled value. When provided, Input syncs to this value. |
| `initial_value` | `string\|nil` | `nil` | Initial value for uncontrolled mode. |
| `placeholder` | `string\|nil` | `nil` | Shown when input is empty and unfocused. |
| `on_change` | `function\|nil` | `nil` | Fires on every text change. Receives the new value. |
| `on_submit` | `function\|nil` | `nil` | Fires on `<CR>` in insert mode. Receives the current value. |
| `on_blur` | `function\|nil` | `nil` | Fires when exiting insert mode. Receives the current value. |
| `password` | `boolean\|nil` | `false` | When `true`, displays `*` instead of actual characters. |

### Controlled vs Uncontrolled

- **Uncontrolled**: Pass `initial_value`. The Input manages its own internal state. Use `on_change`, `on_submit`, `on_blur` to react to changes.
- **Controlled**: Pass `value`. The parent owns the state. Use `on_change` to update the parent's state.

---

## Select

A list of selectable options. One option is selected at a time.

```lua
local Select = ui.components.Select

Select({
    title = "Choose a fruit:",
    options = { "Apple", "Banana", "Cherry", "Date" },
    on_select = function(selected)
        print("You chose: " .. selected)
    end,
})
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `options` | `string[]` | *(required)* | List of option labels to display. |
| `title` | `string\|nil` | `nil` | Optional title rendered above the options. |
| `on_select` | `function\|nil` | `nil` | Callback fired when an option is selected. Receives the option label. |

### Behavior

- Options are rendered as `[x] label` (selected) or `[ ] label` (unselected)
- Navigate with Tab/Shift-Tab, select with `<CR>`
- First option is selected by default

---

## Slider

A horizontal slider with a draggable thumb. Values range from 0 to 100 in steps of 10.

```lua
local Slider = ui.components.Slider

Slider({
    title = "Volume",
    value = 50,
    on_change = function(value)
        print("Volume: " .. value .. "%")
    end,
})
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `title` | `string\|nil` | `""` | Optional title rendered above the slider. |
| `value` | `integer\|nil` | `0` | Initial value (0–100). |
| `on_change` | `function\|nil` | `nil` | Callback fired when the value changes. Receives the new value. |

### Behavior

- Navigate to the thumb with Tab
- Press `<CR>` to enter slider mode
- Use Left/Right arrow keys to decrease/increase the value
- Visual: `────●───── 50%`

---

## Checkbox

Displays a checkbox with a label. purely visual — pair with `useState` for interactive toggling.

```lua
local Checkbox = ui.components.Checkbox
local useState = ui.hooks.useState

local TodoItem = ui.createComponent("TodoItem", function(props)
    local checked, setChecked = useState(false)
    return Checkbox({
        active = checked,
        label = props.text,
    })
end)
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `active` | `boolean\|nil` | `false` | When `true`, displays `[x]`. Otherwise `[ ]`. |
| `label` | `string\|nil` | `""` | Text displayed next to the checkbox. |

### Note

Checkbox is a **display-only** component. To make it interactive, wrap it in a component with `useState` and a `Button` or custom interaction.

---

## Tree

A recursive, collapsible tree view. Supports nested nodes with expand/collapse toggling.

```lua
local Tree = ui.components.Tree

Tree({
    tree = {
        text = "root",
        expanded = true,
        children = {
            {
                text = "src",
                expanded = true,
                children = {
                    { text = "main.lua" },
                    { text = "utils.lua" },
                },
            },
            {
                text = "tests",
                expanded = false,
                children = {
                    { text = "main_spec.lua" },
                },
            },
            { text = "README.md" },
        },
    },
})
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `tree` | `TreeNode` | *(required)* | The root node of the tree. |
| `level` | `integer\|nil` | `0` | Internal. Nesting depth (used for recursion). |
| `has_siblings` | `boolean\|nil` | `false` | Internal. Whether this node has sibling nodes. |
| `is_last` | `boolean\|nil` | `false` | Internal. Whether this is the last child. |

### TreeNode

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `text` | `string` | *(required)* | Label for this node. |
| `children` | `TreeNode[]\|nil` | `nil` | Child nodes. If absent or empty, this is a leaf. |
| `expanded` | `boolean\|nil` | `true` | Whether children are visible initially. |

### Behavior

- Nodes with children show `▸` (collapsed) or `▾` (expanded)
- Click or press `<CR>` on a node to toggle expand/collapse
- Leaf nodes display with `╰─` prefix
- Branch nodes use `├─` and `│` for tree structure

---

## Box

A rounded box with centered text content. Uses the configured box-drawing characters.

```lua
local Box = ui.components.Box

Box({
    width = 20,
    height = 5,
    content = "Hello!",
})

-- Output:
-- ╭──────────────────╮
-- │                  │
-- │      Hello!      │
-- │                  │
-- ╰──────────────────╯
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `width` | `integer\|nil` | `15` | Total width of the box (including borders). |
| `height` | `integer\|nil` | `3` | Total height of the box (including borders). |
| `content` | `string\|nil` | `""` | Text to display centered inside the box. |

### Note

Box uses the characters from `config.characters` for borders. Customize them via `ui.setup()`.

---

## Composing Components

Components can be composed to build complex UIs:

```lua
local ui = require("ascii-ui")
local Paragraph = ui.components.Paragraph
local Button = ui.components.Button
local Input = ui.components.Input
local useState = ui.hooks.useState

local TodoApp = ui.createComponent("TodoApp", function()
    local items, setItems = useState({})
    local input, setInput = useState("")

    return {
        Paragraph({ content = "=== Todo List ===" }),
        Paragraph({ content = "" }),
        Input({
            value = input,
            placeholder = "Add a task...",
            on_change = function(v) setInput(v) end,
            on_submit = function(v)
                if v ~= "" then
                    table.insert(items, v)
                    setItems(items)
                    setInput("")
                end
            end,
        }),
        Paragraph({ content = "" }),
        unpack(ui.map(items, function(item, i)
            return Paragraph({ content = i .. ". " .. item })
        end)),
    }
end)

ui.mount(TodoApp)
```

## Rendering Lists

Use `ui.map` to render arrays of data as components:

```lua
local items = { "Apple", "Banana", "Cherry" }

-- Inside a component:
unpack(ui.map(items, function(item, index)
    return Paragraph({ content = index .. ". " .. item })
end))
```

`ui.map` wraps `vim.iter` and returns a flat table of rendered elements.
