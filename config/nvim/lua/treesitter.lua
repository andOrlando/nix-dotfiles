local opt = vim.opt

require("nvim-treesitter.configs").setup {
	ensure_installed = "maintained",
	highlight = {
		enable = true
	}
}

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
