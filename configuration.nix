{ config, pkgs, ... }:

# Get the unstable tarball
let
  home-manager = fetchTarball https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz;
  asusctl = pkgs.callPackage ./programs/asusctl {};
  supergfxctl = pkgs.callPackage ./programs/supergfxctl {};
  awesome = pkgs.callPackage ./programs/awesome {};
in
{
  imports = [ 
    /etc/nixos/hardware-configuration.nix
    #./programs/waydroid
	./programs/supergfxd
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
	networkmanager.enable = true;
  };

  sound.enable = true;

  hardware = {
    bluetooth = { enable = true; settings.General.Enable = "Source,Sink,Media,Socket"; };
	pulseaudio = {
	  enable = true;
	};
  };

  users.users = {
    bennett = {
      isNormalUser = true;
	  shell = pkgs.fish;
	  #shell = pkgs.bash;
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

  services.supergfxd.enable = true;
  services.supergfxd.mode = "Hybrid"; # set mode to integrated
  services.asusd.enable = true; # asusd from ./programs/asusd
  #services.power-profiles-daemon.enable = true;
  services = {

    #openssh.enable = true; #allow ssh
    upower.enable = true; #battery for awesome
    blueman.enable = true; #gui bluetooth
    #mpd.enable = true;
	tlp.enable = true; # power manager daemon

    xserver = {
      enable = true;
      resolutions = [
        {
          x = 2560;
          y = 1600;
		}
        {
          x = 2048;
          y = 1280;
		}
	  ];

      layout = "us";
      libinput.enable = true; # tablet config
      wacom.enable = true;

      windowManager.session = pkgs.lib.singleton {
        name = "awesomeDEBUG";
        start = "exec dbus-run-session -- ${awesome}/bin/awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr";
      };

      displayManager.gdm.enable = true;

      displayManager.sessionCommands = ''
        # remove caps lock
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e "remove Lock = Caps_Lock"
      '';
    };

	#pipewire = {
	#  enable = true;
	#  alsa.enable = true;
	  #alsa.support32Bit = true;
	#  jack.enable = true;
	  #pulse.enable = true;
	#  socketActivation = true;
	#};

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


