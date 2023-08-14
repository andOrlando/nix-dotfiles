{ pkgs, ... }:
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
  chadtree = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "chadtree";
    src = pkgs.fetchFromGitHub {
      owner = "ms-jpq";
      repo = "chadtree";
      rev = "440ee1d02a1b75a19d56507733737ce11bd02dc6";
      sha256 = "0nzk7kp3pqaq2cwx3jmn9891ric0ncjcyx6vvql20i31zglabpcz";
    };
  };

in
{

  home.packages = with pkgs; [ ctags ];

  programs.nvim = {
    package = pkgs.neovim-unwrapped;
    enable = true;
    vimAlias = true;

    extraConfig = "luafile /etc/nixos/users/bennett/nvim/init.lua";

    plugins = with pkgs.vimPlugins; [

      # frontend changes
      telescope-nvim      # fuzzy search
      telescope-fzf-native-nvim # fuzzy search +
      galaxyline-nvim     # status line plugin
      chadtree            # files
      nvim-tree-lua
      indentLine          # indentlines
      dashboard-nvim      # dashboard TODO: configure
      vim-clap            # for dashboard TODO: configure dashboard
      comment-nvim        # easy commenting TODO: configure
      vim-matchup         # better % key
      gitsigns-nvim       # shows additions and deletions and stuff in gutter
      hop-nvim            # better movement
      nvim-comment        # commments
      presence-nvim       # discord presence lol
      # nvim-autopairs		# pair stuff
      nvim-notify		    # notifications
      zephyr-nvim

      # color stuff
      #nvim-colorizer-lua  # color hex
      vim-hexokinase      # color hex but better
      material-vim        # material colorscheme
      everforest			# more green colorscheme

      # behind-the-scenes stuff 
      vim-gutentags       # tag support
      nvim-treesitter     # better syntax
      vim-nix             # better nix syntax
      vimtex              # gooooood
      lspkind-nvim        # icons for stuff
      #friendly-snippets   # snippet presets
      #luasnip
      nvim-dap		    # testing/debugging
      editorconfig-nvim

      # lsp stuff
      nvim-lspconfig      # lsp core
      nvim-lsp-installer  # lsp installation
      nvim-lsputils       # better lsp stuff
      nvim-cmp            # completion
      cmp-path
      cmp-calc
      cmp-buffer
      cmp-nvim-lsp
      #cmp-nvim-lua
      #lspsaga             # code action

      #cmp-copilot
      #copilot-vim         # breaks cmp tab https://github.com/hrsh7th/nvim-cmp/issues/459

    ];
  };
}
