# ascii-ui.nvim

## Example

```lua

local Box = require("ascii-ui.components.box")
local ui = require("ascii-ui")
local uv = vim.uv

local function setInterval(interval, callback)
 local timer = assert(uv.new_timer())
 timer:start(interval, interval, function()
  callback()
 end)
 return timer
end

local box = Box:new({
 width = 40,
 height = 10,
})

ui.render(box)

setInterval(1000, function()
 local time = os.date("%H:%M:%S") ---@cast time string
 box:set_child(time)
end)

```
