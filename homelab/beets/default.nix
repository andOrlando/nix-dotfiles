{ config, lib, pkgs, ... }:
let
  service = "beets";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service}= {
    enable = lib.mkEnableOption "enable ${service}";
    musicdir = lib.mkOption {
      type = lib.types.str;
      description = "music directory for beets to import to";
    };
    statedir = lib.mkOption {
      type = lib.types.str;
      description = "default directory for all beet state";
      default = "/var/lib/beets";
    };
    config = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      description = "config that will be yamlized, if left empty will use default";
      default = null;
    };
  };
  config = lib.mkIf cfg.enable
  {
    systemd.tmpfiles.rules = map (x: "d ${x} 0775 ${homelab.user} ${homelab.group} - -") [
      cfg.statedir
      cfg.musicdir
    ];
    environment.systemPackages = 
      let
        defaultConfig = {
          directory = cfg.musicdir;
          plugins = [ "duplicates" "info" "fetchart" ];
          import.languages = "en";
          ui.color = true;
        };
        config = if builtins.isNull cfg.config then defaultConfig else cfg.config;
        configfile = (pkgs.formats.yaml {}).generate "beets.yaml" config;
        beet-wrapped = pkgs.writeScriptBin
          "beet-${homelab.user}"
          "sudo -u ${homelab.user} BEETSDIR=${cfg.statedir} ${lib.getExe pkgs.beets} -c ${configfile} \"$@\"";
      in
      [ beet-wrapped ];
  };
}
