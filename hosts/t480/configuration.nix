{ config, pkgs, unstable, nix-tmodloader, ... }:
{
  imports = [ 
    ./hardware-configuration.nix

    ../common/basic.nix
    # ../common/wacom.nix

    nix-tmodloader.nixosModules.tmodloader
  ];

  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
    };
  };

  networking.hostName = "t480";
  users.users = {
    beni = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      hashedPassword = "$6$cq5vs/AUW9kQQRMa$vkpwakgVn7Hn9/o04tCF8fsSoWuaYMEF0YPvxv4CGHeZD7esZn8tEAeqnJT4Cz7/Yl6nTQ9gsZ6vS1vDR6eC50";
    };
  };

  programs.steam.enable = true;

  services.upower.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 100;

     START_CHARGE_THRESH_BAT0 = 0;
     STOP_CHARGE_THRESH_BAT0 = 80;
     START_CHARGE_THRESH_BAT1 = 0;
     STOP_CHARGE_THRESH_BAT1 = 80;
    };
  };


  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.displayManager.sx.enable = true;
  environment.systemPackages = with pkgs; [ sway git texlab ];

  time.hardwareClockInLocalTime = true;
  time.timeZone = "America/New_York";

  system.stateVersion = "21.05"; # Keep this the same for cool stuff


  services.tmodloader.enable = true;
  services.tmodloader.makeAttachScripts = true;
  services.tmodloader.servers.test = {
    enable = true;
    install = [ 2824688072 2824688266 ];
  };
  services.tmodloader.servers.test2 = {
    enable = true;
    port = 7778;
  };


  
}
