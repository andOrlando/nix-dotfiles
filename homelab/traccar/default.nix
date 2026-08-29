{ config, lib, pkgs, ... }:
let
  service = "traccar";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    homepage = lib.helpers.mkStringDefaults {
      category = "utilities";
      description = "find people";
      url = "${homelab.basedomain}:8081";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      settings = {
        webPort = "8081";
#        osmandPort = "5056";
      };
    };
  };
}
