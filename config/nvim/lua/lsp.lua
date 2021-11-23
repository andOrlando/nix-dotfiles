--on attatch callback
local function oac(client, bufnr)
	require("folding").on_attatch()
end


--Compe stuff
vim.o.completeopt = "menuone,noselect"
require("compe").setup {
	enabled = true,
	autocomplete = true,
	source = {
		path = true,
		buffer = true,
		nvim_lsp = true,
		nvim_lua = true,
		tags = true,
		treesitter = true,
	},
}


--Nix LSP stuff
require("lspconfig").rnix.setup {on_attatch = oac}

require("lspconfig").rust_analyzer.setup {on_attath = oac}

--Lua LSP stuff
require("lspconfig").sumneko_lua.setup {on_attatch = oac}

local sumneko_root_path = vim.fn.stdpath('cache')..'/lspconfig/sumneko_lua/lua-language-server'
local sumneko_binary = "lua-language-server"

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require'lspconfig'.sumneko_lua.setup {
  cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = runtime_path,
      },
      diagnostics = { globals = {'vim'} },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
    },
  },
}

-- LspInstaller stuff
local lsp_installer = require("nvim-lsp-installer")
lsp_installer.settings {log_level = vim.log.levels.DEBUG}

lsp_installer.on_server_ready(function(server)
	local opts = {on_attatch = oac}
	server:setup(opts)
end)


