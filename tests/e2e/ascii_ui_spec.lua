local child = MiniTest.new_child_neovim()
local eq = MiniTest.expect.equality

-- ==== Helpers ===============================================

local T = MiniTest.new_set({
	pre_case = function()
		child.restart({ "-u", "scripts/minimal.lua" }) -- --headless con tu minimal_init.lua
		-- Asegúrate de que el RTP incluye tu repo y deps en scripts/minimal_init.lua
		-- y que se puede require("ascii-ui")
		-- child.lua('vim.cmd("filetype plugin indent off")')
	end,
	post_once = child.stop,
})

T["Interacciones en Segment con useState"] = function()
	eq(1, 2)
end

return T
