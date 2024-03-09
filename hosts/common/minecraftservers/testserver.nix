{ pkgs, nix-minecraft, ... }:
{
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];
  services.minecraft-servers = {
    enable = true;
    eula = true;
  };
  services.minecraft-servers.servers.testserver = {
    enable = true;
    autoStart = false;
    package = pkgs.vanillaServers.vanilla-1_20_4;
    openFirewall = true;
    serverProperties = {
      server-port = 25567;
      difficulty = 2;
      gamemode = 1;
      max-players = 2;
      motd = "testing :3";
    };

  };
}
