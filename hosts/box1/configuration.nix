{ config, pkgs, ... }:
{
  imports = [ 
    ./hardware-configuration.nix

    ../common/basic.nix
    ../common/printing.nix
    ../common/wacom.nix
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

  networking.hostName = "zephyrus";
  users.users = {
    bennett = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
    };
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;
    steam.enable = true;
  };

  # asus stuff
  services.asusd.enable = true; # asusd from ./programs/asusd
  services.supergfxd.enable = true;
  programs-rog-controol-center.enable = true;
  environment.etc."supergfxd.conf" = {
    mode = "0644";
    source = (pkgs.formats.json { }).generate "supergfxd.conf" {
      mode = "Integrated";
      vfio_enable = true;
      vfio_save = true;
      always_reboot = false;
      no_logind = true;
      logout_timeout_s = 180;
      hotplug_type1 = "Asus";
    };
  };

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.displayManager.sx.enable = true;

  time.hardwareClockInLocalTime = true;
  time.timeZone = "America/New_York";

  system.stateVersion = "21.05"; # Keep this the same for cool stuff
}
