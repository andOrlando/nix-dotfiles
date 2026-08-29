{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Language servers
    nil
    lua-language-server
    # rust-analyzer
    python3Packages.python-lsp-server
    typescript-language-server
    clang-tools
    gopls
  ];

  programs.helix = {
    enable = true;

    settings = {
      theme = "onedark";
      editor.mouse = false;
    };
  
    languages.language = [
      {
        name = "markdown";
        soft-wrap = {
          enable = true;
          wrap-at-text-width = true;
        };
      }
      {
        name = "latex";
        soft-wrap = {
          enable = true;
          wrap-at-text-width = true;
        };
      }
    ];
    languages.language-server.texlab.config.texlab = {
      build.onSave = true;
      build.forwardSearchAfter = true;
      forwardSearch.executable = "zathura";
      forwardSearch.args = ["--synctex-forward" "%l:1:%f" "%p"];
      chktex.onEdit = true;
    };
    languages.language-server.rust-analyzer.config.check = {
      command = "clippy";
    };
  };
}
