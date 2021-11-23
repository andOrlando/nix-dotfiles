{ config, pkgs, ... }:

let
  zshSettings = import ./config/zsh/zsh.nix;
  nvimSettings = import ./config/nvim/nvim.nix;
in
{
  nixpkgs.config = import ./nixpkgs-config.nix;

  programs.home-manager.enable = true;
  home.username = "bennett";
  home.homeDirectory = "/home/bennett";
  home.stateVersion = "21.11";

  home.packages = with pkgs; [

    # Development Stuff
    kitty          # the one true terminal
    android-studio # android development

    # Langauges TODO: Just use nix shell
    nodejs           # javascript
    lua              # lua
    python           # python
    sage             # python but math

    # Language servers
    rnix-lsp         # not supported by lspinstaller
    sumneko-lua-language-server # binary doesn't work
    rust-analyzer    # binary doesn't work

    # CLI tools
    htop             # top but cooler
    killall          # kills stuff easily
    git              # VCS
    wget             # something useful
    unzip            # useful
    exa              # ls++
    ctags            # tags for gutentags

    # Useful system stuff
    blueman          # bluetooth
    flameshot        # screenshot TODO: Replace with xclip or smthn

    # Normal GUI applications
    brave            # web browsing but weird
    google-chrome    # web browsing but proprietary
    discord          # "ChAt fOr GaMeRs"
    lutris           # gaming
    muse             # DAW
    signal-desktop   # "chat for ~gamers~ privacy nerds"
    xournalpp        # drawing thing
    gnome.nautilus   # files

    # Ricing stuff
    brightnessctl    # brightness for awesomeWM
    picom            # compositor
    playerctl        # player control
    rofi             # better than dmenu TODO: Replace with awesome

    #(callPackage ./config/whitakers-words { })

  ];

  # Heavy config programs
  programs.neovim = nvimSettings pkgs;
  programs.zsh = zshSettings pkgs;

  # GTK stuff
  gtk.enable = true;
  gtk.theme = { name = "Adapta-Nokto"; package = pkgs.adapta-gtk-theme; };
  gtk.iconTheme = { name = "Tela-pink-dark"; package = pkgs.tela-icon-theme; };
  gtk.gtk3.extraConfig = { gtk-decoration-layout = "appmenu:none"; };
  gtk.gtk2.configLocation = "${config.xdg.configHome}/.gtkrc-2.0";

  # XDG dirs
  xdg.userDirs = {
    enable = true;
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    videos = "${config.home.homeDirectory}/media";
    music = "${config.home.homeDirectory}/music";
    pictures = "${config.home.homeDirectory}/media";
    desktop = "${config.home.homeDirectory}/Desktop";
  };

  home.sessionVariables = {
    ANDROID_SDK_HOME="${config.home.homeDirectory}/.config";
    EDITOR="nvim";
  };
}
