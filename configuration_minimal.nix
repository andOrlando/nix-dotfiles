{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

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

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable kde plasma desktop environment
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "us";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver.libinput.enable = true;

  users.users = {
    bennett = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
      hashedPassword = "$6$cq5vs/AUW9kQQRMa$vkpwakgVn7Hn9/o04tCF8fsSoWuaYMEF0YPvxv4CGHeZD7esZn8tEAeqnJT4Cz7/Yl6nTQ9gsZ6vS1vDR6eC50";
    };
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    vim
    wget
    firefox
	gnome.gnome-power-manager
	powertop
  ];

  system.stateVersion = "21.05";

}

