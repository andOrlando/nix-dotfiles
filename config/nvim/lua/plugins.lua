local g = vim.g

--colorizer stuff
require("colorizer").setup()

--nvimtree stuff
vim.api.nvim_set_keymap("n", "<c-n>", ":NvimTreeToggle<cr>", {noremap=true, silent=true})

--Chadtree stuff (doesn't work)
local chadtree_settings = {
	xdg = true;
}
g.chadtree_settings = chadtree_settings
