{ config, lib, ... }:
let
  service = "navidrome";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    mediaLocation = lib.mkOption {
      type = lib.types.str;
      description = "path to store music for navidrome";
      default = "/mnt/md0/music";
    };
    homepage = lib.helpers.mkStringDefaults {
      category = "media";
      description = "music";
      url = "${homelab.basedomain}:4533";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.mediaLocation} 0775 ${homelab.user} ${homelab.group} - -"
    ];
    services.${service} = {
      enable = true;
      group = homelab.group;
      openFirewall = true;
      settings = {
        MusicFolder = "${cfg.mediaLocation}";
        DefaultDownsamplingFormat = "aac";
        Address = "0.0.0.0";
      };
    };
  };
}
