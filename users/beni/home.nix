{ pkgs, config, ... }:
{
  imports = [
    ../config/sway-minimal.nix
    ../config/git.nix
    ../config/bash.nix
    ../config/helix.nix
    # ../config/vscode.nix
  ];

  programs.home-manager.enable = true;
  home.username = "beni";
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "21.11";

  services.spotifyd.enable = true;
  home.packages = with pkgs; [

   (callPackage ../../programs/awesome.nix {})
  
    # insomnium
    brightnessctl
    kitty

    spotify-tui

    # Langauges
    nodejs           # javascript
    lua              # lua
    python3          # python
    python3Packages.pip
    gcc              # for some nvim thing
    gnumake

    # CLI tools
    htop             # top but cooler
    killall          # kills stuff easily
    wget             # something useful
    unzip            # useful
    eza              # ls++
    ffmpeg-full      # audio
    xorg.xkill       # really really kills stuff

    # Useful system stuff
    pavucontrol      # audio

    # Normal GUI applications
    discord          # discord
    unstable.signal-desktop
    gnome.nautilus   # files
    obs-studio       # desktop recording
    kcolorchooser
    zathura          # pdf viewer
    unstable.zoom-us # ugh zoom
    bitwarden        # password manager
    unstable.spotify # I have premium now lol
    slack
    chromium
    firefox
    sx

    # for CS610
    unstable.eclipses.eclipse-java

    unstable.texlab
    (texlive.combine {
      inherit (texlive) scheme-medium
        parskip;
    })
  ];

  # programs.ncmpcpp.enable = true;

  xdg.configFile."kitty".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/users/config/kitty";
  xdg.configFile."awesome".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/users/config/awesome";

  # GTK stuff
  gtk.theme = { name = "Adapta-Nokto"; package = pkgs.adapta-gtk-theme; };
  gtk.iconTheme = { name = "Papirus"; package = pkgs.papirus-icon-theme; };
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

  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory"=["org.gnome.Nautilus.desktop"];
      "text/html" = ["firefox.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
      "x-scheme-handler/about" = ["firefox.desktop"];
      "x-scheme-handler/unknown" = ["firefox.desktop"];
      "application/pdf" = ["org.pwmt.zathura.desktop"];
      "x-scheme-handler/notion"=["notion-app-enhanced.desktop"];
      "x-scheme-handler/bitwarden"=["Bitwarden.desktop"];

    };
  };

  home.sessionVariables = {
    ANDROID_SDK_HOME = "${config.home.homeDirectory}/.config";
    DEFAULT_BROWSER = "${pkgs.chromium}/bin/chromium";
  };
}
