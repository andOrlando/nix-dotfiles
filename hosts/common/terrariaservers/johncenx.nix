{ pkgs, nix-tmodloader, ... }:
{
  imports = [ nix-tmodloader.nixosModules.terraria-server ];
  services.terraria-server.enable = true;
  services.terraria-server.makeAttachScripts = true;
  services.terraria-server.servers.johncenx = {
    enable = true;
    world = /var/lib/terraria/John_Cenx.wld;
    password = "hi";

    openFirewall = true;
    port = 7777;
  };
}
