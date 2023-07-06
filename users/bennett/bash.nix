{
  programs.bash = {
    enable = true;
    historyFile = "$HOME/.local/state/bash_hist";
    shellAliases = {
      unziptar = "tar -xvzf";
      ls = "exa --icons --sort extension";
      tree = "exa --icons --sort extension --tree";
      rebuild = "$NIXOS_CONFIG_DIR/rebuild.sh";
      home = "$EDITOR $NIXOS_CONFIG_DIR/users/$USER/home.nix";
      config = "$EDITOR $NIXOS_CONFIG_DIR/hosts/$(hostname)/configuration.nix";
      gsudo = "sudo git -c \"include.path=$HOME/.config/git/config\"";
    };
    sessionVariables = {
      PS1 = "heyo ";
    };
  };
}
