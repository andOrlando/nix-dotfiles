pkgs:
let
  fast-syntax-highlighting = {
    name = "fast-syntax-highlighting";
    src = pkgs.fetchFromGitHub {
      owner = "zdharma-continuum";
      repo = "fast-syntax-highlighting";
      rev = "817916dfa907d179f0d46d8de355e883cf67bd97";
      sha256 = "0m102makrfz1ibxq8rx77nngjyhdqrm8hsrr9342zzhq1nf4wxxc";
    };
  };
in
{
  enable = true;
  enableCompletion = true;

  dotDir = ".config/zsh";

  initExtra = ''
    PROMPT="%F{141}%n%f:%F{135}%m %F{8}%~ "$'\n'"%(?.%F{4}%B\$%b.%F{9}?) %f"
    RPROMPT=""
    bindkey -v
  '';

  history = {
    save = 1000;
    size = 1000;
    path = "$HOME/.cache/zsh_history";
  };

  shellAliases = {
    unziptar = "tar -xvzf";
    ls = "exa";
    tree = "exa --tree";
    home = "nvim $NIXOS_CONFIG_DIR/home.nix";
    config = "nvim $NIXOS_CONFIG_DIR/configuration.nix";
    rebuild = "sudo nixos-rebuild switch -I nixos-config=$HOME/.config/nixos/configuration.nix";
  };

  plugins = [ fast-syntax-highlighting ];
  oh-my-zsh = {
    enable = true;
    plugins = [ "z" ];
  };
}
