{ pkgs, ... }:
{
  # Fix for using Xinput mode on 8bitdo Ultimate C controller
  # Inspired by https://aur.archlinux.org/packages/8bitdo-ultimate-controller-udev
  
  environment.systemPackages = [pkgs.xboxdrv];

  # Udev rules to start or stop systemd service when controller is connected or disconnected
  services.udev.extraRules = ''
    # May vary depending on your controller model, find product id using 'lsusb'
    SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", ATTR{idProduct}=="310a", ATTR{manufacturer}=="8BitDo", RUN+="${pkgs.systemd}/bin/systemctl start 8bitdo-ultimate-xinput@2dc8:310a"
    # This device (2dc8:301a) is "connected" when the above device disconnects
    SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", ATTR{idProduct}=="301a", ATTR{manufacturer}=="8BitDo", RUN+="${pkgs.systemd}/bin/systemctl stop 8bitdo-ultimate-xinput@2dc8:310a"
  '';

  # Systemd service which starts xboxdrv in xbox360 mode
  systemd.services."8bitdo-ultimate-xinput@" = {
    unitConfig.Description = "8BitDo Ultimate Controller XInput mode xboxdrv daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.xboxdrv}/bin/xboxdrv --mimic-xpad --silent --type xbox360 --device-by-id %I --force-feedback";
    };
  };
}
