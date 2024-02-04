{ pkgs, nix-minecraft, ... }:
{
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];
  services.minecraft-servers = {
    enable = true;
    eula = true;
  };
  services.minecraft-servers.servers.tiffserver = {
    enable = true;
    whitelist = {
      andOrlando = "4c9cf2f1-beac-4422-a268-67d47c7b951a";
      p1nkuu = "649918d9-249f-44e3-b73d-b8299ad93007";
    };
    package = pkgs.vanillaServers.vanilla-1_20_4;
    openFirewall = true;
    serverProperties = {
      server-port = 25565;
      difficulty = 2;
      gamemode = 0;
      max-players = 2;
      motd = "ehyo";
    };

  };
}
