{ config, lib, pkgs, ... }:
let
  service = "nextcloud";
  cfg = config.homelab.${service};
  homelab = config.homelab;
in
{
  options.homelab.${service} = {
    enable = lib.mkEnableOption "enable ${service}";
    domain = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = "domain for nextcloud";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port Nextcloud's nginx vhost listens on";
    };
    homepage = lib.helpers.mkStringDefaults {
      category = "utils";
      description = "nextcloud";
      url = "${homelab.basedomain}:${cfg.port}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service}= {
      enable = true;
      package = pkgs.pkgs.nextcloud32;
      hostName = "localhost";
      https = false;
      config.dbtype = "sqlite";
      config.adminpassFile = "/etc/nextcloud-admin-pass";
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps)
        news
        calendar
        tasks
        richdocuments
        spreed;
      };
      # TODO this is hardcoded this is bad
      settings.trusted_domains = [ "${cfg.domain}:${toString cfg.port}" ];
      settings.overwrite.cli.url = "http://${cfg.domain}:${toString cfg.port}";
    };

    # override the auto-generated vhost to listen on a custom port instead of 80/443
    services.nginx.virtualHosts."localhost" = {
      listen = [ { addr = "0.0.0.0"; port = cfg.port; } ];
      forceSSL = lib.mkForce false;
      addSSL = lib.mkForce false;
      locations."^~ /browser" = {
        proxyPass = "http://127.0.0.1:9980";
        extraConfig = "proxy_set_header Host $host;";
      };
      locations."^~ /hosting/discovery" = {
        proxyPass = "http://127.0.0.1:9980";
        extraConfig = "proxy_set_header Host $host;";
      };
      locations."^~ /hosting/capabilities" = {
        proxyPass = "http://127.0.0.1:9980";
        extraConfig = "proxy_set_header Host $host;";
      };
      # All /cool/* paths go to Collabora. Using ^~ (prefix with priority) to prevent
      # Nextcloud's regex locations (e.g. ~ \.php(?:$|/)) from matching first — the WS
      # URI embeds a WOPI URL with %2Findex.php%2F, and nginx decodes %2F before regex
      # evaluation, which made /cool/.../ws match the PHP handler.
      #
      # Nested location ~ for WebSocket upgrade headers. $request_uri preserves the
      # original path with encoded slashes intact (coolwsd rejects decoded slashes).
      locations."^~ /cool/" = {
        proxyPass = "http://127.0.0.1:9980";
        extraConfig = ''
          proxy_set_header Host $host;

          location ~ ^/cool/(.*)/ws$ {
            proxy_pass http://127.0.0.1:9980$request_uri;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
            proxy_read_timeout 36000s;
          }
        '';
      };
      locations."^~ /cool/adminws" = {
        proxyPass = "http://127.0.0.1:9980";
        extraConfig = ''
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "Upgrade";
          proxy_set_header Host $host;
          proxy_read_timeout 36000s;
        '';
      };
    };
    # for collabora
    services.collabora-online = {
      enable = true;
      port = 9980; # default
      settings = {
        ssl = {
          enable = false;
          termination = false;
        };
        net = {
          listen = "loopback";
          post_allow.host = [ "::1" ];
        };
        storage.wopi = {
          "@allow" = true;
          host = [ cfg.domain ];
        };
        server_name = "box1:8080";
      };
    };
    systemd.services.nextcloud-config-collabora = let
      inherit (config.services.nextcloud) occ;
      wopiUrl = "http://[::1]:${toString config.services.collabora-online.port}";
      publicWopiUrl = "http://${cfg.domain}:${toString cfg.port}/collabora";
      wopiAllowlist = lib.concatStringsSep "," [ "127.0.0.1" "::1" ];
    in {
      wantedBy = [ "multi-user.target" ];
      after = [ "nextcloud-setup.service" "coolwsd.service" ];
      requires = [ "coolwsd.service" ];
      script = ''
        ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopiUrl}
        ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg publicWopiUrl}
        ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopiAllowlist}
        ${occ}/bin/nextcloud-occ richdocuments:setup
      '';
      serviceConfig.Type = "oneshot";
    };
  };
}
