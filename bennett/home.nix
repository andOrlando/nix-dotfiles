{ config, pkgs, lib, ... }:

let
  zshSettings = import ./zsh.nix;
  fishSettings = import ./fish.nix;
  nvimSettings = import ./nvim/nvim.nix;
  kittySettings = import ./kitty.nix;
  gitSettings = import ./git.nix;

  whitakers-words = pkgs.callPackage ../programs/whitakers-words {};
  gdlauncher = pkgs.callPackage ../programs/gdlauncher {};
  librewolf = pkgs.callPackage ../programs/librewolf {};
  gcolor = pkgs.callPackage ../programs/gcolor3 {};
  picom-ibhagwan = pkgs.callPackage ../programs/picom-ibhagwan {};
  spotify-adblock = pkgs.callPackage ../programs/spotify-adblock {};
  
  discord = pkgs.discord.overrideAttrs (old: rec { src = builtins.fetchTarball "https://dl.discordapp.net/apps/linux/0.0.20/discord-0.0.20.tar.gz"; });
in
{
  nixpkgs.config = import ../nixpkgs-config.nix;

  programs.home-manager.enable = true;
  home.username = "bennett";
  home.homeDirectory = "/home/bennett";
  home.stateVersion = "21.11";

  home.packages = with pkgs; [

    # Development Stuff
    android-studio

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
    whitakers-words  # latin dictionary
    ffmpeg-full      # audio
    xorg.xkill       # really really kills stuff
	ripgrep			 # probably good idk but telescope wants it
	sage			 # because sage is cool

    # Useful system stuff
    blueman          # bluetooth
    flameshot        # screenshot TODO: Replace with xclip or smthn
    pavucontrol      # audio

    # Normal GUI applications
    discord          # "ChAt fOr GaMeRs"
    lutris           # gaming
    osu-lazer        # more gaming
    muse             # DAW
    pkgs.unstable.signal-desktop   # "chat for ~gamers~ privacy nerds"
    xournalpp        # drawing thing
    gnome.nautilus   # files
    obs-studio       # desktop recording
    kcolorchooser
    gdlauncher       # minecfraft
    zathura          # pdf viewer
    zoom-us          # ugh zoom
    qutebrowser      # luakit but stable
    bitwarden        # password manager
    spotify          # you need spotify to log into spotify-adblock idk why
    spotify-adblock  # spotify but without ads, simple as that
	gnome.gnome-power-manager
	notion-app-enhanced # notion
	libreoffice
	slack

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
  programs.kitty = kittySettings pkgs;
  programs.git = gitSettings;
  programs.vscode = {
    enable = true;
    userSettings = {
      "java.configuration.runtimes" = [
        {
          name = "JavaSE-17";
          path = "${pkgs.jdk17_headless}/lib/openjdk";
          default = true;
        }
      ];
	  "java.jdt.ls.java.home" = "${pkgs.jdk17_headless}/lib/openjdk";
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
  
  xdg.configFile."luakit".source = config.lib.file.mkOutOfStoreSymlink ./luakit;
  xdg.configFile."awesome".source = config.lib.file.mkOutOfStoreSymlink ./awesome;
  xdg.configFile."qutebrowser".source = config.lib.file.mkOutOfStoreSymlink ./qutebrowser;
  xdg.configFile."picom".source = config.lib.file.mkOutOfStoreSymlink ./picom;
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

  home.sessionVariables = {
    ANDROID_SDK_HOME="${config.home.homeDirectory}/.config";
  };
}
