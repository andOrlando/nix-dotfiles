{ config, lib, ... }:
let
  service = "immich";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    mediaLocation = lib.mkOption {
      type = lib.types.str;
      description = "path to store images for immich";
      default = "/var/lib/immich";
    };
    port = lib.mkOption {
      type = lib.types.int;
      description = "port to host immich web ui on";
      default = 2283;
    };
    homepage = lib.helpers.mkStringDefaults {
      category = "media";
      description = "images";
      url = "${homelab.basedomain}:${toString cfg.port}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      group = homelab.group;
      port = cfg.port;
      openFirewall = true;
      mediaLocation = cfg.mediaLocation;
      host = "0.0.0.0";
    };
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.enable [ cfg.port ];
  };
}
