
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

local Options = require("ascii-ui.components.options")
local layout = require("ascii-ui.layout")
local ui = require("ascii-ui")

local projects = Options:new({
 title = "Project",
 options = {
  "Gradle - Groovy",
  "Gradle - Kotlin",
  "Maven",
 },
})

local langs = Options:new({
 title = "Language",
 options = {
  "Java",
  "Kotlin",
  "Groovy",
 },
})

local spring = Options:new({
 title = "Spring Boot",
 options = {
  "3.5.0 (SNAPSHOT)",
  "3.4.3",
  "3.3.10",
 },
})

ui.mount(layout:new(projects, langs, spring))

```
