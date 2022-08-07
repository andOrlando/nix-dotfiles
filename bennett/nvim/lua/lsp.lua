
local opts = { noremap=true, silent=true }
-- See `:help vim.lsp.*` for documentation on any of the below functions
vim.keymap.set('n', '\\A', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
vim.keymap.set('n', '\\a', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)

--on attatch callback
local function on_attatch(_, bufnr) --[[for buffer specific mappings, this doesn't work atm]] end


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
require("lspconfig").rnix.setup {on_attatch = on_attatch}

--Rust LSP stuff
require("lspconfig").rust_analyzer.setup {on_attatch = on_attatch}

--Lua LSP stuff

local sumneko_root_path = vim.fn.stdpath('cache')..'/lspconfig/sumneko_lua/lua-language-server'
local sumneko_binary = "lua-language-server"

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require'lspconfig'.sumneko_lua.setup {
	on_attatch = on_attatch,
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
	local opts = {on_attatch = on_attatch}
	server:setup(opts)
end)


