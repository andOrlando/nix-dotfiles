{ config, pkgs, ... }:

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

    # Langauges TODO: Just use nix shell
    nodejs           # javascript
    lua              # lua
    python38         # python
    pipenv           # who needs nix-shell with pipenv
    texlive.combined.scheme-medium

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
    gcc              # for some nvim thing
    xdotool          # macros
    whitakers-words  # latin dictionary
    ffmpeg-full      # audio
    xorg.xkill       # really really kills stuff

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
    spotify          # music but its bad and annoying

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
  
  xdg.configFile."luakit".source = config.lib.file.mkOutOfStoreSymlink ./luakit;
  xdg.configFile."awesome".source = config.lib.file.mkOutOfStoreSymlink ./awesome;
  xdg.configFile."qutebrowser".source = config.lib.file.mkOutOfStoreSymlink ./qutebrowser;
  xdg.configFile."picom".source = config.lib.file.mkOutOfStoreSymlink ./picom;

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
