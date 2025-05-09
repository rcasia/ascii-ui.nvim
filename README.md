<img align="right" width="100px" src="./logo.png" alt="Ascii-UI Logo" />

[![codecov](https://codecov.io/gh/rcasia/ascii-ui.nvim/graph/badge.svg?token=J5ISORZOQF)](https://codecov.io/gh/rcasia/ascii-ui.nvim)

# ascii-ui.nvim

A WIP extensible ui framework with no non-sense apis (hopefully) for nvim.

```lua
return {
  { 
  "rcasia/ascii-ui.nvim", 
  opts = {}
 },
}
```

## Example

```lua

local ui = require("ascii-ui")
local Layout = ui.layout.fun
local Select = ui.components.select
local Slider = ui.components.slider

ui.mount(Layout(
 Select({
  title = "Project",
  options = {
   "Gradle - Groovy",
   "Gradle - Kotlin",
   "Maven",
  },
 }),
 Select({
  title = "Language",
  options = {
   "Java",
   "Kotlin",
   "Groovy",
  },
 }),
 Select({
  title = "Spring Boot",
  options = {
   "3.5.0 (SNAPSHOT)",
   "3.4.3",
   "3.3.10",
  },
 }),
 Slider({ value = 50 })
))

```
