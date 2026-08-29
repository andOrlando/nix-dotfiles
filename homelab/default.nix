{ lib, config, ... }:
let
  cfg = config.homelab;
in
{
  options.homelab = {
    enable = lib.mkEnableOption "enable homelab";
    user = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = "user for all homelab services";
    };
    group = lib.mkOption {
      default = "share";
      type = lib.types.str;
      description = "group for all homelab services";
    };
    basedomain = lib.mkOption {
      default = "box1";
      type = lib.types.str;
      description = "base domain for home server";
    };
  };
  imports = [
    ./homepage
    ./deluge
    ./qbittorrent
    ./immich
    ./navidrome
    ./beets

    ./prowlarr
    ./jackett
    ./sonarr
    ./radarr
    ./bazarr
    ./slskd

    ./jellyfin
    ./jellyseerr

    ./owntracks
    ./traccar
    ./vaultwarden
    ./nextcloud
    ./opencloud
  ];
  config = lib.mkIf cfg.enable {
    users = {
      groups.${cfg.group} = {
        gid = 933;
      };
      users.${cfg.user} = {
        uid = 994;
        isSystemUser = true;
        group = cfg.group;
      };
    };
  };
}

