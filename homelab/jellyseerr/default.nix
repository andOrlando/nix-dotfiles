{ config, lib, ... }:
let
  service = "jellyseerr";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    homepage = lib.helpers.mkStringDefaults {
      category = "media";
      description = "request media";
      icon = "${service}.svg";
      url = "${homelab.basedomain}:5055";
    };
  };
  config = lib.mkIf cfg.enable {
      services.${service} = {
      enable = true;
      openFirewall = true;
    };
  };
}
