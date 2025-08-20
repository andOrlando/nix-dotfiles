{ config, lib, pkgs, ... }:
let
  service = "deluge";
  cfg = config.homelab.${service};
  homelab = config.homelab;
  ns = homelab.services.wireguard-netns.namespace;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    homepage = lib.helpers.mkStringDefaults {
      category = "torrent";
      description = "torrent client";
      url = "${homelab.basedomain}:8112";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      openFirewall = true;
      web.enable = true;
    };
  };
}
