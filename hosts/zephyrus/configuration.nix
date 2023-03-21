{ config, pkgs, unstable, ... }@args:
let
  awesome = pkgs.callPackage ../../programs/awesome {};
  unstable-pkgs = import unstable {system="x86_64-linux"; config.allowUnfree = true;};
in
{
  disabledModules = [ "programs/steam.nix" ];
  imports = [ 
    ./hardware-configuration.nix
    (import "${unstable}/nixos/modules/programs/rog-control-center.nix" (args // {pkgs=unstable-pkgs;}))
    (import "${unstable}/nixos/modules/programs/steam.nix" (args // {pkgs=unstable-pkgs;}))
    (import "${unstable}/nixos/modules/services/hardware/asusd.nix" (args // {pkgs=unstable-pkgs;}))
    (import "${unstable}/nixos/modules/services/hardware/supergfxd.nix" (args // {pkgs=unstable-pkgs;}))
    (import "${unstable}/nixos/modules/services/printing/cups-pdf.nix" (args // {pkgs=unstable-pkgs;}))
  ];

  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = "experimental-features = nix-command flakes";
  };
  environment.variables = {
    EDITOR="hx";
    NIXOS_CONFIG_DIR="/home/bennett/.config/nixos";
  };
  nixpkgs.config = {allowUnfree = true;};

  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_1.override {
    argsOverride = rec {
      version = "6.1.12";
      modDirVersion = "6.1.12";
      src = pkgs.fetchurl {
        url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
        sha256 = "sha256-1HqmdRcJBNzJPuqnyW21TUdqEcXT6M89O5bjZOKg7eo=";
      };
    };
  });
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };

  boot.kernelParams = [ "pcie_aspm.policy=powersupersave" ];

  networking = {
    hostName = "zephyrus";
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
      extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
      hashedPassword = "$6$cq5vs/AUW9kQQRMa$vkpwakgVn7Hn9/o04tCF8fsSoWuaYMEF0YPvxv4CGHeZD7esZn8tEAeqnJT4Cz7/Yl6nTQ9gsZ6vS1vDR6eC50";
    };
  };

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
    extraConfig = ''
      Defaults rootpw
      %wheel ALL=(ALL) NOPASSWD: sudoedit ^/etc/nixos[^[:space:]]*$
    '';
  };

  environment.systemPackages = with pkgs; [ neovim helix gnome.gnome-session ];

  programs = {
    sway.enable = true;
    fish.enable = true;
    adb.enable = true;
    dconf.enable = true;

    #unstable
    rog-control-center.enable = true;
    steam.enable = true;
  };

  # asus stuff
  services.asusd.enable = true; # asusd from ./programs/asusd
  services.supergfxd.enable = true;
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

  # printing stuff
  services.printing.enable = true;
  services.printing.cups-pdf.enable = true;
  services.printing.cups-pdf.instances.bennettpdf.settings = {
    Out = "\${HOME}/Documents";
  };
  hardware.printers.ensureDefaultPrinter = "bennettpdf";

  services = {

    # openssh.enable = true; #allow ssh
    # tlp.enable = true; # power manager daemon
    # upower.enable = true; #battery for awesome
    blueman.enable = true; #gui bluetooth

    xserver = {
      enable = true;
      resolutions = [
        { x = 2560; y = 1600; }
        { x = 2048; y = 1280; }
      ];

      layout = "us";
      libinput.enable = true; # tablet config
      wacom.enable = true;

      # windowManager.session = pkgs.lib.singleton {
        # name = "awesomeDEBUG";
        # start = "exec dbus-run-session -- ${awesome}/bin/awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr";
      # };

      displayManager.sx.enable = true;
      # displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      windowManager.awesome.enable = true;
      windowManager.awesome.package = awesome;
    };
  };


  time.hardwareClockInLocalTime = true;
  time.timeZone = "America/New_York";

  system.stateVersion = "21.05"; # Keep this the same for cool stuff

}


