{ pkgs, config, ... }:
{
  imports = [
    ../config/git.nix
    ../config/bash.nix
    ../config/helix.nix
    # ../config/vscode.nix
  ];

  programs.home-manager.enable = true;
  home.username = "bennett2";
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "21.11";

  home.packages = with pkgs; [
    docker

    # CLI tools
    killall          # kills stuff easily
    wget             # something useful
    unzip            # useful
    eza              # ls++
    ffmpeg-full      # audio
    xorg.xkill       # really really kills stuff

    # Normal GUI applications
    discord          # discord
    unstable.signal-desktop
    unstable.zoom-us # ugh zoom
    slack
    umu-launcher

    prismlauncher

    (wrapOBS { plugins = with pkgs.obs-studio-plugins; [ wlrobs ]; })
  ];

}
