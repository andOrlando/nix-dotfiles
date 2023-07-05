{ pkgs, config, unstable, nix-matlab, ... }:

let
  zshSettings = import ./zsh.nix;
  fishSettings = import ./fish.nix;
  nvimSettings = import ./nvim/nvim.nix;
  # kittySettings = import ./kitty.nix;
  gitSettings = import ./git.nix;
  helixSettings = import ./helix.nix;
  swaySettings = import ./sway.nix;

  whitakers-words = pkgs.callPackage ../../programs/whitakers-words {};
  gdlauncher = pkgs.callPackage ../../programs/gdlauncher {};
  librewolf = pkgs.callPackage ../../programs/librewolf {};
  gcolor = pkgs.callPackage ../../programs/gcolor3 {};
  picom-ibhagwan = pkgs.callPackage ../../programs/picom-ibhagwan {};
  spotify = pkgs.callPackage ../../programs/spotify {};
  save-manager = pkgs.callPackage ../../programs/save-manager {};

  unstable-pkgs = import unstable {system = "x86_64-linux"; config = { allowUnfree = true; };};
  # discord = pkgs.discord.overrideAttrs (old: rec { src = builtins.fetchTarball "https://dl.discordapp.net/apps/linux/0.0.21/discord-0.0.21.tar.gz"; });
  # osu-lazer = pkgs.osu-lazer.overrideAttrs (old: rec {
    # version = "2022.1214.0";
    # src = pkgs.fetchFromGitHub {
      # owner = "ppy";
      # repo = "osu";
      # rev = "2022.1214.0";
      # sha256 = "sha256-XwM5GcPZPA5cwomeZA54zc9kg0lP5TDq3d5j+BMNOlU=";
    # };
  # });

  username = "bennett";
  homeDirectory = "/home/${username}";
  local = if builtins.pathExists "${homeDirectory}/.config/nixos/local.nix"
    then import "${homeDirectory}/.config/nixos/local.nix" else {};
in
{
  nixpkgs.config = {allowUnfree = true;};
  nixpkgs.overlays = [ nix-matlab.overlay ];

  programs.home-manager.enable = true;
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "21.11";
  

  home.packages = with pkgs; [

    matlab

    # Development Stuff
    android-studio
    kitty

    # Langauges
    nodejs           # javascript
    lua              # lua
    python38         # python
    pipenv           # who needs nix-shell with pipenv
    texlive.combined.scheme-medium
    gcc              # for some nvim thing
    cargo			 # rust stuff also for nvim thingy
    rustc

    # Language servers
    rnix-lsp         # not supported by lspinstaller
    sumneko-lua-language-server # binary doesn't work
    rust-analyzer    # binary doesn't work

    # CLI tools
    htop             # top but cooler
    killall          # kills stuff easily
    wget             # something useful
    unzip            # useful
    exa              # ls++
    ctags            # tags for gutentags
    xdotool          # macros
    #whitakers-words  # latin dictionary
    ffmpeg-full      # audio
    xorg.xkill       # really really kills stuff
    ripgrep			     # probably good idk but telescope wants it
    sage			       # because sage is cool
    save-manager     # thing I made

    # Useful system stuff
    blueman          # bluetooth
    flameshot        # screenshot TODO: Replace with xclip or smthn
    pavucontrol      # audio

    # Normal GUI applications
    discord          # "ChAt fOr GaMeRs"
    lutris           # gaming
    unstable-pkgs.osu-lazer        # more gaming
    muse             # DAW
    unstable-pkgs.signal-desktop   # "chat for ~gamers~ privacy nerds"
    # signal-desktop
    xournalpp        # drawing thing
    gnome.nautilus   # files
    obs-studio       # desktop recording
    kcolorchooser
    gdlauncher       # minecfraft
    unstable-pkgs.prismlauncher
    zathura          # pdf viewer
    zoom-us          # ugh zoom
    qutebrowser      # luakit but stable
    bitwarden        # password manager
    spotify          # adblocked spotify
    # spotify-adblock  # spotify but without ads, simple as that
    gnome.gnome-power-manager
    notion-app-enhanced # notion
    obsidian		 # notion alternative
    appflowy		 # another notion alternative
    libreoffice
    slack
    figma-linux

    # Ricing stuff
    brightnessctl    # brightness for awesomeWM
    picom-ibhagwan   # compositor
    playerctl        # music control
    rofi             # better than dmenu TODO: Replace with awesome
  ];

  # Heavy config programs
  programs.neovim = nvimSettings pkgs;
  #programs.zsh = zshSettings pkgs;
  programs.fish = fishSettings pkgs;
  # programs.kitty = kittySettings pkgs;
  # programs.kitty.enable = true;
  programs.git = gitSettings;
  programs.helix = helixSettings pkgs;
  programs.vscode = {
    enable = true;
    userSettings = {
      "java.configuration.runtimes" = [
        {
          name = "JavaSE-17";
          path = "${pkgs.jdk17}/lib/openjdk";
          default = true;
        }
      ];
	  "java.jdt.ls.java.home" = "${pkgs.jdk17}/lib/openjdk";
    };
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      gruntfuggly.todo-tree
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "vscode-java-pack";
        publisher = "vscjava";
        version = "0.25.2022082700";
        sha256 = "sha256-Ntock5NjRojqAMlEJBBiPDovOGt5XEuuCugGlmuB4QY=";
      }
      {
        name = "vscode-eslint";
        publisher = "dbaeumer";
        version = "2.2.6";
        sha256 = "sha256-1yZeyLrXuubhKzobWcd00F/CdU824uJDTkB6qlHkJlQ=";
      }
    ];
  };
  
  wayland.windowManager.sway = swaySettings;
  
  # xdg.configFile."luakit".source = config.lib.file.mkOutOfStoreSymlink "${local.configrir}/users/bennett/luakit";
  xdg.configFile."awesome".source = config.lib.file.mkOutOfStoreSymlink
    (if local ? configdir then "${local.configdir}/users/bennett/awesome" else ./awesome);
  xdg.configFile."kitty".source = config.lib.file.mkOutOfStoreSymlink
    (if local ? configdir then "${local.configdir}/users/bennett/kitty" else ./kitty);
  # xdg.configFile."qutebrowser".source = config.lib.file.mkOutOfStoreSymlink "${local.configrir}/users/bennett/qutebrowser";
  # xdg.configFile."picom".source = config.lib.file.mkOutOfStoreSymlink "${local.configrir}/users/bennett/picom";
  #xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink ./nvim;

  # GTK stuff
  gtk.enable = true;
  gtk.theme = { name = "Adapta-Nokto"; package = pkgs.adapta-gtk-theme; };
  #gtk.iconTheme = { name = "Tela-pink-dark"; package = pkgs.tela-icon-theme; };
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
    ANDROID_SDK_HOME="${config.home.homeDirectory}/.config";
    DEFAULT_BROWSER = "${pkgs.librewolf}/bin/librewolf";
  };
}
