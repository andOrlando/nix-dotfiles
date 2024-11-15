{ config, lib, pkgs, ... }:
{
  # home.packages = with pkgs; [ brightnessctl slurp wl-clipboard ];

  wayland.windowManager.sway = {
    enable = true;
    config = {

      modifier = "Mod4";
      menu = "rofi -show drun";
      terminal = "kitty";
      keybindings = let mod = config.wayland.windowManager.sway.config.modifier;

      in lib.mkOptionDefault {
        "${mod}+p" = "exec grim -g \"$(slurp -d)\" - | wl-copy";
        "XF86MonBrightnessDown" = "exec brightnessctl s 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl s +5%";
        "XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
        "XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'";
        "XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
      };
      window = {
        border = 4;
        titlebar = true;
      };
      fonts.size = 13.0;
      
      # output.eDP-1 = {
      #   scale = "1.5";
      #   # bg = ???
      # };
      # output.eDP-2 = {
      #   scale = "1.5";
      # };
      input."type:touchpad" = {
        tap = "enabled";
      };
    };
  };
  
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = let inherit (config.lib.formats.rasi) mkLiteral; in {
      "*" = {

      	background-color = mkLiteral "@bg";
      	text-color = mkLiteral "@fg";
      };
      "#window" = {
        height = mkLiteral "100%";
        width = mkLiteral "30em";
        location = mkLiteral "west";
        anchor = mkLiteral "west";
        border = mkLiteral "4px";
      	border-color = mkLiteral "@accent";
      };
      "#inputbar" = {
        padding = mkLiteral "8px";
        border = mkLiteral "0px 0px 4px 0px";
      	border-color = mkLiteral "@accent";
      };
      "#prompt" = {
      	text-transform = mkLiteral "bold";
      };
      "#entry" = {
      	padding = mkLiteral "0px 0px 0px 8px";
      	placeholder = "say something :/";
      };
      "#inputbar entry" = {
      	padding-left = mkLiteral "4px";
      };
      "#element-text" = {
      	padding = mkLiteral "0px 8px 0px 8px";
      	highlight = mkLiteral "bold";
      };
      "#element-text selected" = {
      	text-color = mkLiteral "@bg";
      	background-color = mkLiteral "@accent";
      };
    };
  };

  programs.i3status-rust = {
    enable = true;
    bars.top = {
      blocks = [
        { block = "music";
          # format = " $artist - $title ";
          player = "spotify";
        }
        { block = "sound";
        }
        { block = "time";
          format = " $timestamp.datetime(f:'%a %d/%m %R') ";
        }
        { block = "battery";
          format = " $percentage $power ";
          full_format = " $percentage $power ";
        }
      ];
      settings = {
        theme.overrides = {
          separator = ".";
          separator_bg = "auto";
        };
      };
    };
  };
}
