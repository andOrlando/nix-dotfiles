{ config, lib, ... }:
let
  service = "sonarr";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    homepage = lib.helpers.mkStringDefaults {
      category = "torrent";
      description = "show indexing";
      url = "${homelab.basedomain}:8989";
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
