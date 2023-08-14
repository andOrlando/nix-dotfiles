--on attatch callback which apparently doesn't work so kinda just sits here
local function on_attatch(_, bufnr) --[[for buffer specific mappings, this doesn"t work atm]] end

--Nix LSP stuff
require("lspconfig").rnix.setup {on_attatch = on_attatch}

--Rust LSP stuff
require("lspconfig").rust_analyzer.setup {on_attatch = on_attatch}

--Lua LSP stuff
local sumneko_root_path = vim.fn.stdpath("cache").."/lspconfig/sumneko_lua/lua-language-server"
local sumneko_binary = "lua-language-server"

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require"lspconfig".sumneko_lua.setup {
	on_attatch = on_attatch,
    cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
          path = runtime_path,
      },
        diagnostics = { globals = {"vim"} },
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
