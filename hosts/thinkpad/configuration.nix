{ config, pkgs, unstable, ... }@args:
{
  imports = [ 
    ./hardware-configuration.nix

    ../common/basic.nix
    ../common/wacom.nix
  ];

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

  networking.hostName = "thinkpad";
  users.users = {
    bennett = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      hashedPassword = "$6$cq5vs/AUW9kQQRMa$vkpwakgVn7Hn9/o04tCF8fsSoWuaYMEF0YPvxv4CGHeZD7esZn8tEAeqnJT4Cz7/Yl6nTQ9gsZ6vS1vDR6eC50";
    };
  };

  programs.steam.enable = false;

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.displayManager.sx.enable = true;
  environment.systemPackages = with pkgs; [ i3 ];

  time.hardwareClockInLocalTime = true;
  time.timeZone = "America/New_York";

  system.stateVersion = "21.05"; # Keep this the same for cool stuff
}
