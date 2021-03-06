# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

# Get the unstable tarball
let
  home-manager = fetchTarball https://github.com/nix-community/home-manager/archive/master.tar.gz;
  asusctl = pkgs.callPackage ./programs/asusctl {};
  awesome = pkgs.callPackage ./programs/awesome {};
in
{
  imports = [ 
    /etc/nixos/hardware-configuration.nix
    #./programs/waydroid
    ./programs/asusd
    (import "${home-manager}/nixos")
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

  boot.kernelPackages = pkgs.linuxPackages_5_18;
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };

  boot.kernelPatches = [
    { # patches bluetooth for zephyrus g14, use until kernel 5.20
      name = "bluetooth-until-5.20";
      patch = builtins.fetchurl "https://gitlab.com/dragonn/linux-g14/-/raw/5.18/sys-kernel_arch-sources-g14_files-8017-add_imc_networks_pid_0x3568.patch";
    }
  ];


  networking = {
    hostName = "nixos";
    #networkmanager = {enable = true; dhcp = "dhclient";};
    #useDHCP = false; # this is depriciated and so explicity set to false
    #interfaces.wlp1s0.useDHCP = true;
    wireless.enable = true;
    wireless.extraConfig = ''
      ctrl_interface=/run/wpa_supplicant
      ctrl_interface_group=wheel
      update_config=1

      network={
          ssid="The sock thief"
          psk=6185f1ed939227af0840531f0d6503a72513410b064822711089ac89808e5855
      }
      network={
          ssid="QuietDog"
          psk=4882031b922b58349801aff8a3492d4c3e13cceeb4c62a737ec0708eba628b71
      }
  '';

  };

  sound.enable = true;

  hardware = {
    bluetooth = { enable = true; settings.General.Enable = "Source,Sink,Media,Socket"; };
    #pulseaudio.enable = true;
  };

  users.users = {
    bennett = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
      hashedPassword = "$6$cq5vs/AUW9kQQRMa$vkpwakgVn7Hn9/o04tCF8fsSoWuaYMEF0YPvxv4CGHeZD7esZn8tEAeqnJT4Cz7/Yl6nTQ9gsZ6vS1vDR6eC50";
    };
  };

  # home-manager for me
  home-manager.users.bennett = import ./bennett/home.nix;
  # virtualisation.virtualbox.host.enable = true; # for genymotion
  # virtualisation.waydroid11.enable = true; # this comes from the ./programs/waydroid
  



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

  environment.systemPackages = with pkgs; [ vim xorg.xmodmap asusctl ];

  programs = {
    steam.enable = true;
    #zsh.enable = true;
    fish.enable = true;
    adb.enable = true;
    dconf.enable = true;
  };

  services.asusd.enable = true; # asusd from ./programs/asusd
  services = {

    #openssh.enable = true; #allow ssh
    upower.enable = true; #battery for awesome
    blueman.enable = true; #gui bluetooth
    #mpd.enable = true;

    xserver = {
      enable = true;
      layout = "us";
      libinput.enable = true; # tablet config
      wacom.enable = true;

      #windowManager.awesome = {
      #  enable = true;
      #  package = awesome;
      #};
      windowManager.session = pkgs.lib.singleton {
        name = "awesomeDEBUG";
        start = "exec dbus-run-session -- ${awesome}/bin/awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr";
      };

      displayManager.gdm.enable = true;
      displayManager.gdm.wayland = true;

      displayManager.sessionCommands = ''
        # remove caps lock
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e "remove Lock = Caps_Lock"
      '';
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      socketActivation = true;
    };

  };
  programs.sway.enable = true;

  # Open ports in the firewall.
  #networking.firewall = {
  #  enable = false;
    #allowedTCPPorts = [ 5440 ]; # ssh
  #};

  time.hardwareClockInLocalTime = true;
  time.timeZone = "America/New_York";

  system.stateVersion = "21.05"; # Keep this the same for cool stuff

}


