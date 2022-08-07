local g = vim.g
local opt = vim.opt
--colorizer stuff
require("colorizer").setup()

--Chadtree stuff https://github.com/ms-jpq/chadtree
vim.api.nvim_set_keymap("n", "<c-n>", ":CHADopen<cr>", {noremap=true, silent=true})
local chadtree_settings = {
	xdg = true,
	keymap = {
		tertiary = {"<C-T>"},
	}
}
g.chadtree_settings = chadtree_settings
--call v:lua.cmp.utils.keymap.set_map(12486884)

--Treesitter stuff
require("nvim-treesitter.configs").setup {
	ensure_installed = "all",
	highlight = {
		enable = true
	}
}

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"

--comment-nvim https://github.com/numToStr/Comment.nvim
require("Comment").setup()

--nvim cmp https://github.com/hrsh7th/nvim-cmp
local cmp = require "cmp"
cmp.setup {
	completion = { completeopt = "menuone,noselect" },
	formatting = {
		format = function(entry, vim_item)
			local icons = {
				Text = "",
				Method = "",
				Function = "",
				Constructor = "",
				Field = "ﰠ",
				Variable = "",
				Class = "ﴯ",
				Interface = "",
				Module = "",
				Property = "ﰠ",
				Unit = "塞",
				Value = "",
				Enum = "",
				Keyword = "",
				Snippet = "",
				Color = "",
				File = "",
				Reference = "",
				Folder = "",
				EnumMember = "",
				Constant = "",
				Struct = "פּ",
				Event = "",
				Operator = "",
				TypeParameter = "",
			}
			vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)

			vim_item.menu = ({
				path = "[Path]",
				calc = "[Calc]",
				copilot = "[COP]",
				buffer = "[BUF]",
				nvim_lsp = "[LSP]",
				nvim_lua = "[Lua]",
			})[entry.source.name]

			return vim_item
		end
	},
	mapping = {
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.close(),
		["<tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then cmp.select_next_item()
			else fallback() end
		end),
		["<S-tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then cmp.select_prev_item()
			else fallback() end
		end),
		["<CR>"] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
	},
	snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
	sources = {
		{ name = "path" },
		{ name = "calc" },
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
		{ name = "buffer" },
		{ name = "copilot" },
	}
}

function _G.tab_map(bool)
	if cmp.visible() then
		if bool then cmp.select_next_item()
		else cmp.select_prev_item() end
	else vim.api.nvim_feedkeys("	", "n", true) end
end
vim.api.nvim_set_keymap("i", "<tab>", "<cmd>call v:lua.tab_map(v:true)<cr>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("i", "<s-tab>", "<cmd>call v:lua.tab_map(v:false)<cr>", {noremap=true, silent=true})

--lsp_signature https://github.com/ray-x/lsp_signature.nvim
--require("lsp_signature").setup {}

--copilot
--vim.api.nvim_set_keymap("i", "<c-l>", "copilot#Accept()", {silent=true, script=true, expr=true})
--g.copilot_no_tab_map = true --fix tab map thing

--lspsaga
--[[local saga = require 'lspsaga'
saga.init_lsp_saga {border_style="none"}

vim.api.nvim_set_keymap("n", "ca", "<cmd>lua require('lspsaga.codeaction').code_action()<cr>", {noremap=true, silent=true})]]
