{ pkgs, unstable, ... }:
{
  home.packages = with pkgs; [
    # Language servers
    rnix-lsp
    sumneko-lua-language-server
    rust-analyzer
    python311Packages.python-lsp-server
    # (python311Packages.python-lsp-server.overrideAttrs(old: {
      # disabledTests = old.disabledTests ++ [ 
        # "test_in_place_no_modifications_no_writes"
        # "test_in_place_no_modifications_no_writes_with_empty_file"
      # ];
    # }))
    nodePackages_latest.typescript-language-server
  ];

  programs.helix = {
    enable = true;

    settings = {
      theme = "onedark";
      editor.mouse = false;
    };
  
    languages.language = [
      {
        name = "latex";
        config.texlab = {
          build.onSave = true;
          build.forwardSearchAfter = true;
          forwardSearch.executable = "zathura";
          forwardSearch.args = ["--synctex-forward" "%l:1:%f" "%p"];
          chktex.onEdit = true;
        };
      }
    ];
  };
}
