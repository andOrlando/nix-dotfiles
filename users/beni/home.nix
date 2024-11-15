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

  home.packages = with pkgs; [

    # insomnium
    kitty

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
    unstable.signal-desktop-beta # "chat for privacy nerds"
    gnome.nautilus   # files
    obs-studio       # desktop recording
    kcolorchooser
    zathura          # pdf viewer
    zoom-us          # ugh zoom
    bitwarden        # password manager
    unstable.spotify # I have premium now lol
    libreoffice
    slack
    chromium
    librewolf

  ];

  # programs.ncmpcpp.enable = true;

  xdg.configFile."kitty".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/users/config/kitty";

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
