{ lib, pkgs, ... }:
{

  home.packages = with pkgs; [ brightnessctl ];

  programs.i3status = {
    enable = true;
    modules = {
      "battery 0" = {
        position = 1;
        settings = {
          format = "%status %percentage %remaining %emptytime";
          format_down = "No battery";
          status_chr = "charging";
          status_bat = "bat";
          status_unk = "?";
          status_full = "full";
          low_threshold = 10;
        };
      };
      "volume master" = {
        position = 2;
        settings = {
          format = "volume %volume";
          format_muted = "volume muted";
        };
      };
      "tztime local" = {
        position = 3;
        settings = {
          format = "%Y-%m-%d %H:%M:%S";
          hide_if_equals_localtime = true;
        };
      };
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    config = rec {

      modifier = "Mod4";

      terminal = "kitty";
      keybindings = lib.mkOptionDefault {
        "XF86MonBrightnessDown" = "exec brightnessctl s -5%";
        "XF86MonBrightnessUp" = "exec brightnessctl s +5%";
        "XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
        "XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'";
        "XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
      };
    };
  
    extraConfig = ''
      output eDP-1 scale 1.5
    '';
  };
}
