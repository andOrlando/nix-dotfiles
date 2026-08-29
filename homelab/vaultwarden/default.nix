{ config, lib, ... }:
let
  service = "vaultwarden";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    homepage = lib.helpers.mkStringDefaults {
      category = "media";
      description = "password manager";
      url = "${homelab.basedomain}:8000";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      config = {
        DOMAIN = "https://127.0.0.1";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8000;
        EXTENDED_LOGGING = true;
        LOG_LEVEL = "warn";
        IP_HEADER = "CF-Connecting-IP";
      };
    };
  };
}
