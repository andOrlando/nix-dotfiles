{ config, lib, ... }:
let
  service = "lidarr";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    homepage = lib.helpers.mkStringDefaults {
      category = "torrent";
      description = "music indexing";
      url = "${homelab.basedomain}:8686";
    };
  };
  config = lib.mkIf cfg.enable {
      services.${service} = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      openFirewall = true;
    };
  };
}
