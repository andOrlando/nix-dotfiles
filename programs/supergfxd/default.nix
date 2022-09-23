{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.supergfxd;
  configFile = pkgs.writeText "supergfxd.conf" (builtins.toJSON ({
    mode = cfg.mode;
    managed = cfg.managed;
    vfio_enable = cfg.vfio-enable;
	vfio_save = cfg.vfio-save;
	compute_save = cfg.compute-save;
	always_reboot = cfg.always-reboot;
	no_logind = cfg.no-logind;
	logout_timeout_s = cfg.logout-timeout-s;
  }));
  supergfxctl = pkgs.callPackage ../supergfxctl {};
in
{
  ###### interface

  options = {
    services.supergfxd = {
      enable = mkOption {
        description = ''
          Enable this option to enable control of GPU modes with supergfxd.

          This permits you to switch between integrated, hybrid and dedicated
          graphics modes on supported laptops.
        '';
        type = types.bool;
        default = false;
      };
      mode = mkOption {
        description = "Sets the default GPU mode that is applied on boot.";
        type = types.enum [ "Nvidia" "Integrated" "Compute" "Vfio" "Egpu" "Hybrid" ];
        default = "Hybrid";
      };
      managed = mkOption {
        description = "Sets if the graphics management is enabled";
        type = types.bool;
        default = true;
      };
      vfio-enable = mkOption {
        description = "Sets if VFIO-Passthrough of the dedicated GPU is enabled.";
        type = types.bool;
        default = false;
      };
	  vfio-save = mkOption {
		description = "Reload VFIO on boot";
		type = types.bool;
		default = false;
	  };
	  compute-save = mkOption {
		description = "Reload compute on boot";
		type = types.bool;
		default = false;
	  };
	  always-reboot = mkOption {
		description = "Reboot to change modes";
		type = types.bool;
		default = false;
	  };
	  no-logind = mkOption {
		description = "Don't use logind to see if all sessions are logged out and therefore safe to change mode. This will be useful for people not using a login manager, however it is not guaranteed to work unless all graphical sessions are ended and nothing is hooking the drivers. Ignored if always_reboot is set";
		type = types.bool;
		default = false;
	  };
	  logout-timeout-s = mkOption {
		description = "The timeout in seconds to wait for all user graphical sessions to end. Default is 3 minutes, 0 = infinite. Ignored if `no_logind` or `always_reboot` is set.";
		type = types.int;
		default = 180;
	  };
    };
  };

  ###### implementation

  config = mkIf config.services.supergfxd.enable {
    environment.systemPackages = with pkgs; [ supergfxctl ];
    services.dbus.packages = with pkgs; [ supergfxctl ];
    services.udev.packages = with pkgs; [ supergfxctl ];
    systemd.packages = with pkgs; [ supergfxctl ];
    environment.etc."supergfxd.conf".source = configFile;
  };
}
