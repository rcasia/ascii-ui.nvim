---@meta

---@class BustedAssertAre
---@field same fun(expected: any, actual: any): nil
---@field equals fun(expected: any, actual: any): nil

---@class BustedAssert
---@field are BustedAssertAre
---@field is_nil fun(v: any): nil
---@field is_true fun(v: any): nil
---@field is_false fun(v: any): nil
---@field has_error fun(f: function, msg?: string): nil

---@type BustedAssert
assert = assert
