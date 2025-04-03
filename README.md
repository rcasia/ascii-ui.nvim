
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

ui.mount(ui.layout:new(
 ui.components.options:new({
  title = "Project",
  options = {
   "Gradle - Groovy",
   "Gradle - Kotlin",
   "Maven",
  },
 }),
 ui.components.options:new({
  title = "Language",
  options = {
   "Java",
   "Kotlin",
   "Groovy",
  },
 }),
 ui.components.options:new({
  title = "Spring Boot",
  options = {
   "3.5.0 (SNAPSHOT)",
   "3.4.3",
   "3.3.10",
  },
 }),
 ui.components.slider:new(50)
))

```
