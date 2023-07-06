{ lib, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    config = rec {

      modifier = "Mod4";

      terminal = "kitty";
      keybindings = lib.mkOptionDefault {
        "XF86MonBrightnessDown" = "exec light -U 10";
        "XF86MonBrightnessUp" = "exec light -A 10";
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
