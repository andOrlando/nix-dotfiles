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

  # hardware.opengl.enable = true;
  services.spotifyd.enable = true;
  home.packages = with pkgs; [

    # (callPackage ../../programs/awesome.nix {})
    unstable.claude-code
    baobab
    docker
  
    # insomnium
    brightnessctl
    kitty

    # Langauges
    go
    nodejs_24           # javascript
    lua              # lua
    (python3.withPackages(ps: [
      ps.numpy
    ]))    # python
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
    nautilus   # files
    kdePackages.kcolorchooser
    zathura          # pdf viewer
    unstable.zoom-us # ugh zoom
    slack
    chromium
    firefox
    unstable.librewolf
    sx

    prismlauncher

    unstable.texlab
    (texlive.combine {
      inherit (texlive) scheme-full
        pygmentex
        listingsutf8
        pdfcol
        tikzfill
        tcolorbox
        multirow
        libertine
        inconsolata
        newtx
        minted
        ncctools
        ifmtarg
        hyperxmp
        totpages
        xstring
        environ
        lipsum
        makecell
        gensymb
        relsize
        ifoddpage
        cancel
        codesection
        parskip
        enumitem
        comment;
    })

    (wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
      ];
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
      "text/html" = ["librewolf.desktop"];
      "x-scheme-handler/http" = ["librewolf.desktop"];
      "x-scheme-handler/https" = ["librewolf.desktop"];
      "x-scheme-handler/about" = ["librewolf.desktop"];
      "x-scheme-handler/unknown" = ["librewolf.desktop"];
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
