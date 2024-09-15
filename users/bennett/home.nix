{ pkgs, config, lib, ... }:
{
  imports = [
    ../config/sway.nix
    ../config/git.nix
    ../config/bash.nix
    ../config/helix.nix
    # ../config/vscode.nix
  ];

  programs.home-manager.enable = true;
  home.username = "bennett";
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "21.11";

  home.packages = with pkgs; [

    pgadmin4
    podman
    vscode
    unstable.r2modman
    matlab
    (callPackage ../../programs/awesome.nix {})
    awakened-poe-trade
    ryujinx
    pkgsCross.avr.buildPackages.gcc
    avrdude
    gnumake
    # insomnium

    # Development Stuff
    android-studio
    kitty

    # Langauges
    nodejs           # javascript
    lua              # lua
    python38         # python
    gcc              # for some nvim thing

    # CLI tools
    htop             # top but cooler
    killall          # kills stuff easily
    wget             # something useful
    unzip            # useful
    eza              # ls++
    xdotool          # macros
    # whitakers-words  # latin dictionary
    ffmpeg-full      # audio
    xorg.xkill       # really really kills stuff
    sage			       # because sage is cool
    save-manager     # thing I made

    # Useful system stuff
    blueman          # bluetooth
    flameshot        # screenshot TODO: Replace with xclip or smthn
    pavucontrol      # audio

    # Normal GUI applications
    discord          # "ChAt fOr GaMeRs"
    lutris           # gaming
    unstable.osu-lazer # more gaming
    muse             # DAW
    signal-desktop # "chat for ~gamers~ privacy nerds"
    xournalpp        # drawing thing
    gnome.nautilus   # files
    obs-studio       # desktop recording
    kcolorchooser
    unstable.prismlauncher
    zathura          # pdf viewer
    zoom-us          # ugh zoom
    qutebrowser      # luakit but stable
    bitwarden        # password manager
    # spotify-adblock  # spotify is overridden with an adblocked version
    unstable.spotify
    gnome.gnome-power-manager
    notion-app-enhanced # notion
    # obsidian		     # notion alternative
    libreoffice
    slack
    figma-linux
    chromium
    kicad-small

    unstable.path-of-building
    unstable.shotcut
  ];

  programs.ncmpcpp.enable = true;

  xdg.configFile."awesome".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/users/config/awesome";
  xdg.configFile."kitty".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/users/config/kitty";

  # GTK stuff
  gtk.enable = true;
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
      "text/html" = ["chromium.desktop"];
      "x-scheme-handler/http" = ["chromium.desktop"];
      "x-scheme-handler/https" = ["chromium.desktop"];
      "x-scheme-handler/about" = ["chromium.desktop"];
      "x-scheme-handler/unknown" = ["chromium.desktop"];
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
