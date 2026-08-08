# Expected Behavior

## Agent Actions

1. **Search documentation**: Agent looks for floating window APIs in Neovim docs
2. **Identify functions**: Agent finds relevant API functions
3. **Extract signatures**: Agent documents function signatures
4. **Explain usage**: Agent describes what each function does
5. **Show relationships**: Agent explains how functions work together
6. **Cite sources**: Agent references help tags or documentation

## Expected APIs Covered

- `nvim_open_win()` - Create floating window
- `nvim_win_set_config()` - Update window configuration
- `nvim_win_get_config()` - Get window configuration
- `nvim_win_close()` - Close floating window
- `nvim_win_set_buf()` - Set buffer in window
- Related buffer functions if relevant

## Expected Output Format

```
## Floating Window APIs

### nvim_open_win()

**Signature**: `nvim_open_win({buffer}, {enter}, {config})`

**Description**: Creates a floating window...

**Parameters**:
- `buffer` (number): Buffer handle
- `enter` (boolean): Whether to enter the window
- `config` (table): Window configuration

**Returns**: Window handle

**Help tag**: `:help nvim_open_win()`

### nvim_win_set_config()
[Similar structure]

## Usage Pattern

[Example showing how to create and configure a floating window]

## Related APIs

[List of related functions]
```

## Expected Sources

- `:help api-window`
- `:help nvim_open_win()`
- `:help floating-windows`
- Project source code examples in `lua/ascii-ui/window/`
