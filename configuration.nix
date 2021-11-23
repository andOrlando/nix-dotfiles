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
  ];

  environment.variables = {
    NIXOS_CONFIG="$HOME/.config/nixos/configuration.nix";
    NIXOS_CONFIG_DIR="$HOME/.config/nixos";
    EDITOR="nvim";
  };

  # Do unstable stuff
  nixpkgs.config = import ./nixpkgs-config.nix;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;

  # Kernel patch for anbox
  boot.kernelPatches = [
      {
        name = "ashmem-binder";
        patch = null;
        extraConfig = ''
          ASHMEM y
          ANDROID y
          ANDROID_BINDER_IPC y
          ANDROID_BINDERFS y
          ANDROID_BINDER_DEVICES binder,hwbinder,vndbinder
        '';
      }
  ];

  networking.hostName = "beniiii";
  networking.networkmanager.enable = true;
  networking.networkmanager.dhcp = "dhclient";
  networking.useDHCP = false; # this is depriciated and so explicity set to false
  networking.interfaces.wlp1s0.useDHCP = true;

  sound.enable = true;

  hardware = {
    bluetooth = { enable = true; settings.General.Enable = "Source,Sink,Media,Socket"; };
    pulseaudio.enable = true;
  };

  users.users = {
    bennett = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "networkmanager" ];
    };
    ssh = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
    };
  };

  # home-manager for me
  home-manager.users.bennett = import ./home.nix;

  # Enable sudo and add correct config
  security.sudo = {
    enable = true;
    extraConfig = "Defaults rootpw";
  };

  environment.systemPackages = with pkgs; [ vim ];

  programs.steam.enable = true;
  programs.zsh.enable = true;
  programs.dconf.enable = true;

  services = {

    #openssh.enable = true;
    blueman.enable = true; #gui bluetooth

    xserver = {
      enable = true;
      layout = "us";
      libinput.enable = true; # tablet config

      windowManager.awesome = {
        enable = true;
        package = pkgs.awesome.overrideDerivation (old: rec {
          buildInputs = old.buildInputs ++ [ pkgs.upower pkgs.playerctl ];
        });
      };

      # TODO: Make cooler
      displayManager = {
        sddm.enable = true;
        defaultSession = "none+awesome";
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    #allowedTCPPorts = [ 5440 ]; # ssh
  };


  time.hardwareClockInLocalTime = true;

  system.stateVersion = "21.05"; # Keep this the same for cool stuff


}

