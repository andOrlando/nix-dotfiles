{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Language servers
    nil
    lua-language-server
    # rust-analyzer
    python3Packages.python-lsp-server
    typescript-language-server
    rustup
    clang-tools
    gopls
    ltex-ls-plus
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
        language-servers = ["texlab" "ltex-ls-plus"];
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
    languages.language-server.ltex-ls-plus.config.ltex = {
      diagnosticSeverity = "warning";
      disabledRules = { en-US = ["PROFANITY"]; en-GB = ["PROFANITY"]; };
      dictionary = { en-US = ["builtin"]; en-GB = ["builtin"]; };
    };
  };
}
