pkgs:
let
  nvim-lsp-installer = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-lsp-installer";
    src = pkgs.fetchFromGitHub {
      owner = "williamboman";
      repo = "nvim-lsp-installer";
      rev = "35d4b08d60c17b79f8e16e9e66f0d7693c99d612";
      sha256 = "1zf9r6qg8s8zz2n63fmz01xphvyz1jxg1bqy4mdlglj2h16i2jpj";
    };
  };
  material-vim = pkgs.vimUtils.buildVimPlugin {
    name = "material-vim";
    src = pkgs.fetchFromGitHub {
      owner = "kaicataldo";
      repo = "material.vim";
      rev = "3b8e2c32e628f0ef28771900c6d83eb003053b91";
      sha256 = "1wi1brm1yml4xw0zpc6q5y0ql145v1hw5rbbcsgafagsipiz4av3";
    };
  };
in
{
  package = pkgs.unstable.neovim-unwrapped;
  enable = true;
  vimAlias = true;

  #extraConfig is broken for me
  configure.customRC = ''
    luafile /etc/nixos/config/nvim/lua/settings.lua
  '';

  plugins = with pkgs.vimPlugins; [

    # frontend changes
    telescope-nvim      # fuzzy search
    galaxyline-nvim     # status line plugin
    nvim-tree-lua       # tree pulgin
    nvim-web-devicons   # nerdfont stuff
    indentLine          # indentlines

    # color stuff
    nvim-colorizer-lua  # color hex
    material-vim        # material colorscheme

    # behind-the-scenes stuff 
    vim-gutentags       # tag support
    nvim-treesitter     # better syntax
    vim-nix             # better nix syntax

    # lsp stuff
    nvim-lspconfig      # lsp core
    nvim-compe          # lsp completion
    nvim-lsp-installer  # lsp installation

  ];
}
