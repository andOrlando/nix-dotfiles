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
  coq-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "coq_nvim";
    src = pkgs.fetchFromGitHub {
      owner = "ms-jpq";
      repo = "coq_nvim";
      rev = "77e5987b8a13342910da9ee1ba9c49f0aeb49b7e";
      sha256 = "16cjpjblnp92wdnh2nf6dk8iv67y4n33k92gkq3rb035q62ryyzj";
    };
  };
  copilot-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "copilot.vim";
    src = pkgs.fetchFromGitHub {
      owner = "github";
      repo = "copilot.vim";
      rev = "c01314840b94da0b9767b52f8a4bbc579214e509";
      sha256 = "10vw2hjrg20i8id5wld8c5b1m96fnxvkb5qhbdf9w5sagawn4wc2";
    };
  };
  cmp-copilot = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "cmp-copilot";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-copilot";
      rev = "104f6784351911d39e11f4edeaf43dc9ecc23cc2";
      sha256 = "0fa6a3m5hf3f7pdbmkb4dnczvcvr6rr3pshvdwkqy62v08h1vdyk";
    };
  };
  lspsaga = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "lspsaga";
    src = pkgs.fetchFromGitHub {
      owner = "tami5";
      repo = "lspsaga.nvim";
      rev = "d8073a0e4d19d71da900fb77dcc5f23d72bb8707";
      sha256 = "0f5qzi9kk02z6siqzwz2zak687zb4q2nkg66x3pnnqvhfqazjb5q";
    };
  };
  luasnip = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "luasnip";
    src = pkgs.fetchFromGitHub {
      owner = "L3MON4D3";
      repo = "LuaSnip";
      rev = "eb84bb89933141fa0cd0683cb960fef975106dfd";
      sha256 = "09lwf4n1qzvb98k9sq2m66671fdlni81iaskxdirq97smfyhxg8k";
    };
  };
in
{
  package = pkgs.unstable.neovim-unwrapped;
  enable = true;
  vimAlias = true;

  #extraConfig is broken for me
  #extraConfig = ''
  configure.customRC = ''
    luafile /etc/nixos/bennett/nvim/lua/settings.lua
  '';

  plugins = with pkgs.vimPlugins; [

    # frontend changes
    #telescope-nvim      # fuzzy search
    galaxyline-nvim     # status line plugin
    chadtree            # files
    indentLine          # indentlines
    dashboard-nvim      # dashboard TODO: configure
    vim-clap            # for dashboard TODO: configure dashboard
    comment-nvim        # easy commenting TODO: configure
    vim-matchup         # better % key

    # color stuff
    nvim-colorizer-lua  # color hex
    material-vim        # material colorscheme

    # behind-the-scenes stuff 
    vim-gutentags       # tag support
    nvim-treesitter     # better syntax
    vim-nix             # better nix syntax
    vimtex              # gooooood
    friendly-snippets   # snippet presets
    luasnip

    # lsp stuff
    nvim-lspconfig      # lsp core
    nvim-lsp-installer  # lsp installation
    nvim-lsputils       # better lsp stuff
    nvim-cmp            # completion
    cmp-path
    cmp-calc
    cmp-buffer
    cmp-nvim-lsp
    cmp-nvim-lua
    cmp-copilot
    lspsaga             # code action

    #copilot-vim         # breaks cmp tab https://github.com/hrsh7th/nvim-cmp/issues/459


  ];
}
