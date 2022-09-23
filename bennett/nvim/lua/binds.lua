local binds = {}
local opts = { noremap=true, silent=true }
vim.g.mapleader = ' '
vim.g.maplocalleader = ","

--tab binds
for i=1,9 do vim.api.nvim_set_keymap("n", "\\"..i, "<cmd>tabnext "..i.."<cr>", opts) end

--noraml stuff
vim.keymap.set("n", "<leader>~", "<cmd>Dashboard<CR>", opts)
vim.keymap.set("n", "<leader><CR>", "<cmd>vs | terminal<CR>i", opts)
vim.keymap.set("t", "<c-esc>", "<c-\\><c-n>", opts)
vim.keymap.set("", "<c-c>", "<cmd>CommentToggle<CR>", opts)
vim.keymap.set("n", "<c-n>", "<cmd>CHADopen<cr>", opts)

--clipboard stuff
vim.keymap.set("n", "<leader>y", "\"+y", opts)
vim.keymap.set("n", "<leader>yy", "\"+yy", opts)

--telescope stuff
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true })
vim.keymap.set('n', '<leader>fw', ':Telescope live_grep<CR>', { noremap = true })
vim.keymap.set('n', '<leader>fg', ':Telescope git_commits<CR>', { noremap = true })
vim.keymap.set('n', '<leader>fG', ':Telescope git_branches<CR>', { noremap = true })
vim.keymap.set('n', '<leader>fe', ':lua require(\'telescope.builtin\').symbols({ sources = { \'kaomoji\'}})<CR>', { noremap = true })

--hop stuff
vim.keymap.set("n", "<leader>ww", "<cmd>HopWord<CR>", opts)
vim.keymap.set("n", "<leader>wk", "<cmd>HopWordBC<CR>", opts)
vim.keymap.set("n", "<leader>wj", "<cmd>HopWordAC<CR>", opts)
vim.keymap.set("n", "<leader>wl", "<cmd>HopWordCurrentLine<CR>", opts)

-- lsp binds
-- See `:help vim.lsp.*` for documentation on any of the below functions
vim.keymap.set("n", "<leader>A", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
vim.keymap.set("n", "<leader>a", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)

--cmp binds
local cmp = require "cmp"
binds.cmp = {
	--["<C-p>"] = cmp.mapping.select_prev_item(),
	--["<C-n>"] = cmp.mapping.select_next_item(),
	["<C-d>"] = cmp.mapping.scroll_docs(-4),
	["<C-f>"] = cmp.mapping.scroll_docs(4),
	["<C-Space>"] = cmp.mapping.complete(),
	["<C-e>"] = cmp.mapping.close(),
	["<tab>"] = cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() else fallback() end end),
	["<S-tab>"] = cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() else fallback() end end),
	["<CR>"] = cmp.mapping.confirm {
		behavior = cmp.ConfirmBehavior.Replace,
		select = true,
	},
}

binds.gitsigns = {
	noremap = true,
}

return binds
