# https://blog.meain.io/2022/self-hosted-location-history/
# https://github.com/arsfeld/nixos/blob/9bee2688792b67da8f4dae2e97a8736962031083/hosts/cloud/services/owntracks.nix#L4
# https://github.com/mewoocat/NixOS/tree/9c69aea1ccf2a7b4119b1860b37d974656765d6a/modules/servers/owntracks
{ config, lib, pkgs, ... }:
let
  service = "owntracks";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    homepage = lib.helpers.mkStringDefaults {
      category = "utilities";
      description = "find stuff";
      url = "${homelab.basedomain}:8083";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.ot-recorder = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStartPre = "${pkgs.owntracks-recorder}/bin/ot-recorder --initialize";
        ExecStart = "${pkgs.owntracks-recorder}/bin/ot-recorder owntracks/#";
      };
    };

    environment.etc."default/ot-recorder".text = ''
      OTR_STORAGEDIR="/var/lib/ot-recorder"
      OTR_PORT=0
      OTR_HTTPPORT=8083
    '';

    networking.firewall.allowedTCPPorts = [ 1234 ];
    services.caddy = {
      enable = true;
      virtualHosts.":1234".extraConfig = ''
        handle /pub* {
          basicauth {
            owntracks $2a$14$lJ2SDpp8ON9SQImq.3UIz.RCJ80CGQatSV3lQ5.Gapy675Spz3VaG
          }
          reverse_proxy http://localhost:8083
        }
      '';
        #   reverse_proxy http://localhost:8083
        # }
    };
  };
}
