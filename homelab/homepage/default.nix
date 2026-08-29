{ config, lib, ... }:
let
  cfg = config.homelab.homepage;
  homelab = config.homelab;
in
{
  options.homelab.homepage = {
    enable = lib.mkEnableOption "enable homepage";
  };
  config = lib.mkIf cfg.enable {
    services.glances.enable = true;
    services.homepage-dashboard = {
      enable = true;
      openFirewall = true;
      allowedHosts = "*";

      services  =
      let
        hl = config.homelab;
        categories = [ "media" "torrent" "utilities" ];
        getServicesByName = x: (lib.attrsets.mapAttrsToList (name: _: name) (lib.attrsets.filterAttrs (name: value:
              value ? homepage
              && value.homepage ? category
              && value.homepage.category == x
              && value.enable)
            hl
          ));
      in
        lib.lists.forEach categories (cat: {
          "${cat}" = lib.lists.forEach (getServicesByName cat) (service:
            let
              # if we have a name use that, otherwise default to service
              name = if hl.${service}.homepage ? name then hl.${service}.homepage.name else service;
              description = if hl.${service}.homepage ? description then { description = hl.${service}.homepage.description; } else {};
              icon = if hl.${service}.homepage ? icon then { icon = hl.${service}.homepage.icon; } else { icon = "${service}.svg"; };
            in
            {
              "${name}" = {
                href = "http://${hl.${service}.homepage.url}";
                siteMonitor = "http://${hl.${service}.homepage.url}";
            } // description // icon;
          });
        });
      widgets = [
        {
          resources = {
            cpu = true;
            cputemp = true;
            memory = true;
            disk = "/mnt/md0";
            uptime = true;
          };
        }
      ];
    };
    services.caddy = {
      enable = true;
      virtualHosts.":80".extraConfig = "reverse_proxy http://localhost:8082";
      virtualHosts.${homelab.basedomain}.extraConfig = "reverse_proxy http://localhost:8082";
    };
  };
}
