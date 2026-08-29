{ config, lib, ... }:
let
  service = "slskd";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "path to environment variables";
    };
    directories = {
      incomplete = lib.mkOption {
        type = lib.types.path;
        description = "Directory where incomplete downloading files are stored.";
      };
      downloads = lib.mkOption {
        type = lib.types.path;
        description = "Directory where downloaded files are stored.";
      };
    };
    shares = {
      directories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Paths to directories to share";
      };
      filters = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Regex filters to omit files";
        default = [];
      };
    };
    homepage = lib.helpers.mkStringDefaults {
      category = "torrent";
      url = "${homelab.basedomain}:5030";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${homelab.user} ${homelab.group} - -") [
      cfg.directories.incomplete
      cfg.directories.downloads
    ];
    services.${service} = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      openFirewall = true;

      environmentFile = cfg.environmentFile;
      settings.directories = cfg.directories;
      settings.shares = cfg.shares;
      domain = null;

    };
  };
}
