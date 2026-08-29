{  pkgs, nix-tmodloader, ... }:
{
  imports = [ 
    ./hardware-configuration.nix

    ../common/basic.nix
    ../common/sound.nix
    # ../common/8bitdo.nix
    # ../common/wacom.nix

    nix-tmodloader.nixosModules.tmodloader
  ];
  nix.settings.auto-optimise-store = true;
  virtualisation.docker.enable = true;
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      # dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };


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
  programs.adb.enable = true;
  services.tailscale.enable = true;
  # services.postgresql.enable = true;
  # services.postgresql.package = pkgs.postgresql_15;

  services.upower.enable = true;
  services.tlp = {
    enable = false;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "passive";

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
  services.xserver.xkb.layout = "us";
  services.xserver.displayManager.sx.enable = true;
  environment.systemPackages = with pkgs; [
    gpclient
    i3
    sway
    git
    texlab
    libsodium
    czmq
    pkg-config
  ];
  services.gnome.gnome-keyring.enable = true;

  time.hardwareClockInLocalTime = true;
  time.timeZone = "America/New_York";

  system.stateVersion = "21.05"; # Keep this the same for cool stuff

}
