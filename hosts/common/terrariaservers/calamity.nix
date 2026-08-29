{ pkgs, nix-tmodloader, ... }:
{
  imports = [ nix-tmodloader.nixosModules.tmodloader-server ];
  services.tmodloader-server.enable = true;
  services.tmodloader-server.makeAttachScripts = true;
  services.tmodloader-server.steamcmdPackage = pkgs.callPackage ./steamcmd.nix {};
  services.tmodloader-server.servers.calamity = {
    enable = true;
    install = [ 2824688072 2824688266 ];
    openFirewall = true;
    port = 7778;
  };
}
