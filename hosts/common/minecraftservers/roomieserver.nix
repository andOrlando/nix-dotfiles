{ pkgs, nix-minecraft, ... }:
{
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];
  services.minecraft-servers = {
    enable = true;
    eula = true;
  };
  services.minecraft-servers.servers.roomieserver = {
    enable = true;
    autoStart = false;
    package = pkgs.vanillaServers.vanilla-1_20_4;
    openFirewall = true;
    serverProperties = {
      server-port = 25566;
      difficulty = 2;
      gamemode = 0;
      max-players = 4;
      motd = "roomie server";
    };
  };
}
