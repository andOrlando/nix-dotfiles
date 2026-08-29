{ pkgs, palworld-server-flake, ... }:
{
  imports = [ palworld-server-flake.nixosModules.palworld-server ];
  services.palworld-server = {
    enable = true;
    port = 7777;
    openFirewall = true;
  };
}
