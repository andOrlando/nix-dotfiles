{ config, pkgs, unstable, ... }@args:
{
  imports = [ 
    ./hardware-configuration.nix

    ../common/basic.nix
    ../common/printing.nix
    ../common/wacom.nix
    ../common/anime-game.nix

    ../common/tiffserver.nix
    ../common/roomieserver.nix
  ];

  boot.kernelParams = [ "pcie_aspm.policy=powersupersave" ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };

  environment.systemPackages = with pkgs; [
    pkgs.vanillaServers.vanilla-1_20_4
  ];

  networking.hostName = "zephyrus";
  users.users = {
    bennett = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
      hashedPassword = "$6$cq5vs/AUW9kQQRMa$vkpwakgVn7Hn9/o04tCF8fsSoWuaYMEF0YPvxv4CGHeZD7esZn8tEAeqnJT4Cz7/Yl6nTQ9gsZ6vS1vDR6eC50";
    };
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [5000 8080];
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;
    steam.enable = true;
  };

  # asus stuff
  services.asusd.enable = true; # asusd from ./programs/asusd
  services.supergfxd.enable = true;
  programs.rog-control-center.enable = true;
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

  services.udisks2.enable = true;
  
  time.hardwareClockInLocalTime = true;
  time.timeZone = "America/New_York";

  system.stateVersion = "21.05"; # Keep this the same for cool stuff
}
