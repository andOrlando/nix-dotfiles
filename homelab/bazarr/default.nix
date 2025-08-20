{ config, lib, ... }:
let
  service = "bazarr";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    homepage = lib.helpers.mkStringDefaults {
      category = "torrent";
      description = "subtitle manager";
      url = "${homelab.basedomain}:6767";
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
