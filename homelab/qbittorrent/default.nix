{ config, lib, ... }:
let
  service = "qbittorrent";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    port = lib.mkOption {
      type = lib.types.int;
      description = "port to host qbittorrent web ui on";
      default = 8888;
    };
    homepage = lib.helpers.mkStringDefaults {
      category = "torrent";
      url = "${homelab.basedomain}:${toString cfg.port}";
      description = "torrent client";
    };
  };
  config = lib.mkIf cfg.enable {
      services.${service} = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      openFirewall = true;
      webuiPort = cfg.port;
    };
  };
}
