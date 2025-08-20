{ config, lib, ... }:
let
  service = "jellyfin";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    homepage = lib.helpers.mkStringDefaults {
      category = "media";
      url = "${homelab.basedomain}:8096";
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
