{ pkgs, ... }:
{
  imports = [ 
    ./hardware-configuration.nix

    ../common/basic.nix
    ../common/printing.nix
    ../common/wacom.nix

    ../common/minecraftservers/tiffserver.nix
    ../common/minecraftservers/testserver.nix
    ../common/minecraftservers/roomieserver.nix
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
    nix-index
    libsForQt5.kwallet
    libsForQt5.kwalletmanager
    libsForQt5.kwallet-pam
  ];

  programs.noisetorch.enable = true;

  networking.hostName = "zephyrus";
  users.users = {
    bennett = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "libvirtd" "docker"];
      hashedPassword = "$6$cq5vs/AUW9kQQRMa$vkpwakgVn7Hn9/o04tCF8fsSoWuaYMEF0YPvxv4CGHeZD7esZn8tEAeqnJT4Cz7/Yl6nTQ9gsZ6vS1vDR6eC50";
    };
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [8080];
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;
    steam.enable = true;
  };

  programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = with pkgs; [
    # stdenv.cc.cc.lib
    # zlib
  # ];

  services.postgresql.package = pkgs.postgresql;
  services.postgresql.enable = true;

  # services.xserver.desktopManager.plasma5.enable = true;
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
      CPU_MAX_PERF_ON_BAT = 20;

     #Optional helps save long term battery health
     START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
     STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
    };
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
  services.xserver.displayManager.gnomoe.enable = true;

  virtualisation.docker.enable = true;
  
  time.hardwareClockInLocalTime = true;
  time.timeZone = "America/New_York";

  services.openssh.settings = {
    TCPKeepAlive = "yes";
    ClientAliveInterval = 100;
  };

  system.stateVersion = "21.05"; # Keep this the same for cool stuff
}
