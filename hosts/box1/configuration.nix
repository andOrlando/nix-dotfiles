{ config, pkgs, ... }:
{
  imports = [ 
    ./hardware-configuration.nix

    ../common/basic.nix
    ../common/tiffserver.nix
  ];

  environment.variables = {
    EDITOR="hx";
    NIXOS_CONFIG_DIR="/home/bennett/.config/nixos";
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;
  boot.kernelParams = [ "pcie_aspm.policy=powersupersave" ];
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };

  networking.hostName = "box1";
  users.users = {
    bennett = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
    };
  };

  time.hardwareClockInLocalTime = true;
  time.timeZone = "America/New_York";

  system.stateVersion = "21.05"; # Keep this the same for cool stuff
}
