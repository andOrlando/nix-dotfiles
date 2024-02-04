{ pkgs, ... }:
{
  
  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = "experimental-features = nix-command flakes";
  };
  environment.variables.EDITOR="hx";

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General.Enable = "Source,Sink,Media,Socket";
  services.blueman.enable = true;

  sound.enable = true;
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.pulse.enable = true;

  # Enable sudo and add correct config
  security.sudo.enable = true;
  security.sudo.extraConfig = "Defaults rootpw";

  environment.systemPackages = with pkgs; [
    helix
    rebuild
    bc
    pulseaudio
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = [ 
      "JetBrainsMono"
      "FantasqueSansMono"
      "FiraCode"
      "Hasklig"
    ];})
  ];


}
