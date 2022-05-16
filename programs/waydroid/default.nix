{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.virtualisation.waydroid11;
  kernelPackages = config.boot.kernelPackages;
  waydroidGbinderConf = pkgs.writeText "waydroid.conf" ''
    [Protocol]
    /dev/binder = aidl3
    /dev/vndbinder = aidl3
    /dev/hwbinder = hidl

    [ServiceManager]
    /dev/binder = aidl3
    /dev/vndbinder = aidl3
    /dev/hwbinder = hidl
  '';
  waydroidGbinderConfGeneral = pkgs.writeText "gbinder.conf" ''
    [General]
    ApiLevel = 30
  '';
  waydroid11 = pkgs.callPackage ./waydroid.nix {};
in
{

  options.virtualisation.waydroid11 = {
    enable = mkEnableOption "Waydroid";
  };

  config = mkIf cfg.enable {
    assertions = singleton {
      assertion = versionAtLeast (getVersion config.boot.kernelPackages.kernel) "4.18";
      message = "Waydroid needs user namespace support to work properly";
    };

    system.requiredKernelConfig = with config.lib.kernelConfig; [
      (isEnabled "ANDROID_BINDER_IPC")
      (isEnabled "ANDROID_BINDERFS")
      (isEnabled "ASHMEM")
    ];

    /* NOTE: we always enable this flag even if CONFIG_PSI_DEFAULT_DISABLED is not on
      as reading the kernel config is not always possible and on kernels where it's
      already on it will be no-op
    */
    boot.kernelParams = [ "psi=1" ];

    environment.etc."gbinder.d/waydroid.conf".source = waydroidGbinderConf;
    environment.etc."gbinder.conf".source = waydroidGbinderConfGeneral;

    environment.systemPackages = [ waydroid11 ];

    networking.firewall.trustedInterfaces = [ "waydroid0" ];

    virtualisation.lxc.enable = true;

    systemd.services.waydroid-container = {
      description = "Waydroid Container";

      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ getent iptables iproute kmod nftables util-linux which ];

      unitConfig = {
        ConditionPathExists = "/var/lib/waydroid/lxc/waydroid";
      };

      serviceConfig = {
        ExecStart = "${waydroid11}/bin/waydroid container start";
        ExecStop = "${waydroid11}/bin/waydroid container stop";
        ExecStopPost = "${waydroid11}/bin/waydroid session stop";
      };
    };
  };
}
