--on attatch callback
local function oac(_, bufnr)
	require("folding").on_attatch()

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local opts = { noremap=true, silent=true }
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    --vim.api.nvim_buf_set_keymap(bufnr, 'n', 'wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    --vim.api.nvim_buf_set_keymap(bufnr, 'n', 'wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    --vim.api.nvim_buf_set_keymap(bufnr, 'n', 'wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    --vim.api.nvim_buf_set_keymap(bufnr, 'n', 'D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    --vim.api.nvim_buf_set_keymap(bufnr, 'n', 'rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<c-a>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    --vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
end


-- other thing stuff
if vim.fn.has('nvim-0.5.1') == 1 then
    vim.lsp.handlers['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
    vim.lsp.handlers['textDocument/references'] = require'lsputil.locations'.references_handler
    vim.lsp.handlers['textDocument/definition'] = require'lsputil.locations'.definition_handler
    vim.lsp.handlers['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
    vim.lsp.handlers['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
    vim.lsp.handlers['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
    vim.lsp.handlers['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
    vim.lsp.handlers['workspace/symbol'] = require'lsputil.symbols'.workspace_handler
else
    local bufnr = vim.api.nvim_buf_get_number(0)
    vim.lsp.handlers['textDocument/codeAction'] = function(_, _, actions) require('lsputil.codeAction').code_action_handler(nil, actions, nil, nil, nil) end
    vim.lsp.handlers['textDocument/references'] = function(_, _, result) require('lsputil.locations').references_handler(nil, result, { bufnr = bufnr }, nil) end
    vim.lsp.handlers['textDocument/definition'] = function(_, method, result) require('lsputil.locations').definition_handler(nil, result, { bufnr = bufnr, method = method }, nil) end
    vim.lsp.handlers['textDocument/declaration'] = function(_, method, result) require('lsputil.locations').declaration_handler(nil, result, { bufnr = bufnr, method = method }, nil) end
    vim.lsp.handlers['textDocument/typeDefinition'] = function(_, method, result) require('lsputil.locations').typeDefinition_handler(nil, result, { bufnr = bufnr, method = method }, nil) end
    vim.lsp.handlers['textDocument/implementation'] = function(_, method, result) require('lsputil.locations').implementation_handler(nil, result, { bufnr = bufnr, method = method }, nil) end
    vim.lsp.handlers['textDocument/documentSymbol'] = function(_, _, result, _, bufn) require('lsputil.symbols').document_handler(nil, result, { bufnr = bufn }, nil) end
    vim.lsp.handlers['textDocument/symbol'] = function(_, _, result, _, bufn) require('lsputil.symbols').workspace_handler(nil, result, { bufnr = bufn }, nil) end
end


--Nix LSP stuff
require("lspconfig").rnix.setup {on_attatch = oac}

require("lspconfig").rust_analyzer.setup {on_attath = oac}

--Lua LSP stuff

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


