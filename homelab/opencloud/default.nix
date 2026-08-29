{ config, lib, pkgs, ... }:
let
  service = "opencloud";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    homepage = lib.helpers.mkStringDefaults {
      category = "utilities";
      description = "files";
      url = "${homelab.basedomain}:8084";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      webPackage = pkgs.unstable.opencloud.web;
      idpWebPackage = pkgs.unstable.opencloud.idp-web;
      url = "https://${homelab.basedomain}:8083";
      address = "127.0.0.1";
      port = 8084;
      environment = {
        PROXY_TLS="false";
      };
      environmentFile = "/etc/opencloud-admin-pass";
    };
    services.caddy = {
      virtualHosts."${homelab.basedomain}:8083".extraConfig = "reverse_proxy http://localhost:8084";
    };

  };
}
