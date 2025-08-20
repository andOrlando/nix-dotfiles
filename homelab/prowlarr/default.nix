{ config, lib, ... }:
let
  service = "prowlarr";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    homepage = lib.helpers.mkStringDefaults {
      category = "torrent";
      description = "indexer manager";
      url = "${homelab.basedomain}:9696";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      openFirewall = true;
    };
    services.flaresolverr.enable = true;
  };
}
