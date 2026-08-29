{ pkgs, stable, ... }:
{
  
  nix = {
    nixPath = ["nixpkgs=${stable}"];
    package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
  };
  environment.variables.EDITOR="hx";
  networking.networkmanager.enable = true;

  # Enable sudo and add correct config
  security.sudo.enable = true;
  security.sudo.extraConfig = "Defaults rootpw";

  environment.systemPackages = with pkgs; [
    helix
    rebuild
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fantasque-sans-mono
  ];


}
