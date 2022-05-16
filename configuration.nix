# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

# Get the unstable tarball
let
  home-manager = fetchTarball https://github.com/nix-community/home-manager/archive/master.tar.gz;
in
{
  imports = [ 
    /etc/nixos/hardware-configuration.nix
    (import "${home-manager}/nixos")
    ./programs/waydroid
  ];

  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  environment.variables = {
    NIXOS_CONFIG="$HOME/.config/nixos/configuration.nix";
    NIXOS_CONFIG_DIR="$HOME/.config/nixos";
    EDITOR="nvim";
  };

  nixpkgs.config = import ./nixpkgs-config.nix;

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };

  # Kernel patch for anbox
  #boot.kernelPatches = [
  #    {
  #      name = "ashmem-binder";
  #      patch = null;
  #      extraConfig = ''
  #        ASHMEM y
  #        ANDROID y
  #        ANDROID_BINDER_IPC y
  #        ANDROID_BINDERFS y
  #        ANDROID_BINDER_DEVICES binder,hwbinder,vndbinder
  #      '';
  #    }
  #];

  networking = {
    hostName = "nixos";
    networkmanager = {enable = true; dhcp = "dhclient";};
    useDHCP = false; # this is depriciated and so explicity set to false
    interfaces.wlp1s0.useDHCP = true;
  };

  sound.enable = true;

  hardware = {
    bluetooth = { enable = true; settings.General.Enable = "Source,Sink,Media,Socket"; };
    pulseaudio.enable = true;
  };

  users.users = {
    bennett = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
    };
    ssh = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
    };
  };

  # home-manager for me
  home-manager.users.bennett = import ./bennett/home.nix;
  virtualisation.virtualbox.host.enable = true; # for genymotion
  virtualisation.waydroid11.enable = true;
  

  fonts.fonts = with pkgs; [
    (nerdfonts.override {fonts = [ 
      "JetBrainsMono"
      "FantasqueSansMono"
      "FiraCode"
      "Hasklig"
    ];})
  ];

  # Enable sudo and add correct config
  security.sudo = {
    enable = true;
    extraConfig = "Defaults rootpw";
  };

  security.doas = {
    enable = true;
    wheelNeedsPassword = true;
    extraRules = [{ groups = ["wheel"]; persist = true; }];
  };

  environment.systemPackages = with pkgs; [ vim xorg.xmodmap ];

  programs = {
    steam.enable = true;
    zsh.enable = true;
    adb.enable = true;
    dconf.enable = true;
  };

  services = {

    #openssh.enable = true; #allow ssh
    upower.enable = true; #battery for awesome
    blueman.enable = true; #gui bluetooth
    mpd.enable = true;

    xserver = {
      enable = true;
      layout = "us";
      libinput.enable = true; # tablet config
      wacom.enable = true;

      windowManager.awesome = {
        enable = true;
        package = pkgs.awesome.overrideDerivation (old: rec {
          nativeBuildInputs = old.nativeBuildInputs ++ [
            pkgs.playerctl 
            pkgs.lm_sensors
            pkgs.brightnessctl
            #pkgs.acpi
          ];
          # use master rather than 4.3
          src = pkgs.fetchFromGitHub {
            owner = "awesomeWM";
            repo = "awesome";
            rev = "c539e0e4350a42f813952fc28dd8490f42d934b3";
            sha256 = "111sgx9sx4wira7k0fqpdh76s9la3i8h40wgaii605ybv7n0nc0h";
          };
        });
      };

      displayManager.gdm.enable = true;
      displayManager.gdm.wayland = true;

      displayManager.sessionCommands = ''
        # remove caps lock
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e "remove Lock = Caps_Lock"
      '';
    };

  };
  programs.sway.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = false;
    #allowedTCPPorts = [ 5440 ]; # ssh
  };

  time.hardwareClockInLocalTime = true;
  time.timeZone = "America/New_York";

  system.stateVersion = "21.05"; # Keep this the same for cool stuff

}


