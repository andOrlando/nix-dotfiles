{ pkgs, ... }:
{
  # home.packages = with pkgs; [ ];
  
  programs.bash = {
    enable = true;
    historyFile = "$HOME/.local/state/bash_hist";
    shellAliases = {
      unziptar = "tar -xvzf";
      ls = "exa --icons --sort extension";
      tree = "exa --icons --sort extension --tree";
      # rebuild = "$NIXOS_CONFIG_DIR/rebuild.sh";
      home = "$EDITOR /etc/nixos/users/$USER/home.nix";
      config = "$EDITOR /etc/nixos/hosts/$(hostname)/configuration.nix";
      gsudo = "sudo git -c \"include.path=$HOME/.config/git/config\"";
    };
    bashrcExtra = ''
      PS1="\[\e[94;1m\]\u\[\e[39m\]:\[\e[94m\]\h \[\e[0;37m\]$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1 /')\[\e[90m\]\w\n\[\e[0m\]\$ "
    '';
  };
}
