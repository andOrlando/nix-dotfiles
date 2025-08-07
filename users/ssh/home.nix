{ pkgs, config, ... }:
{
  imports = [
    ../config/git.nix
    ../config/bash.nix
    ../config/helix.nix
  ];

  programs.home-manager.enable = true;
  home.username = "ssh";
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "21.11";

  home.packages = with pkgs; [

    # CLI tools
    htop             # top but cooler
    killall          # kills stuff easily
    wget             # something useful
    unzip            # useful
    eza              # ls++

  ];
}
