--add itself to package.path
package.path = package.path .. ";/etc/nixos/bennett/nvim/lua/?.lua"

--require all the cool things
require "settings"
require "plugins"
require "lsp"
require "binds"
